/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 * 
 */
 class Tasks_Road_BuildInnerCity extends Task {
	static INITIALIZE		= 0;
	static PICK_STATIONS    = 2;
    static PREP_VEHICLES    = 3;
    static SELECT_STATION   = 4;
    static BUY_VEHICLES     = 5;
    static FINALIZE         = 6;

	state = 0;
    budget_id = null;
    funds_id = null;
    cargo_id = null;
    town_id = null;
    max_stations = 0;

    engine_id = null;
    tracer = null;
    selected = null;
    builder = null;
    queue = null;
    owned = null;
    current_station = null;
    
	constructor(budget_id, funds_id, cargo_id, town_id, max_stations){
        this.budget_id = budget_id;
        this.funds_id = funds_id;
        this.cargo_id = cargo_id;
        this.town_id = town_id
        this.max_stations = max_stations;
        
		state = INITIALIZE;
	}

    function GetName(){
        return "Road_BuildInnerCity";
    }

    function Run(){
        switch(state){
            case INITIALIZE: return Initialize();
            case PICK_STATIONS: return PickStations();
            case PREP_VEHICLES: return PrepVehicles();
            case SELECT_STATION: return SelectStation();
            case BUY_VEHICLES: return BuyVehicles();
        }

        return false;
    }

    function Initialize(){
        local engines = AIEngineList(AIVehicle.VT_ROAD);
        engines.Valuate(Engine.GetCargoType)
        engines.KeepValue(cargo_id);
        if(engines.IsEmpty()){
            Log.Warning("No road engine found for " + Cargo.GetName(cargo_id));
            return false;
        }

        engines.Sort(AIList.SORT_BY_VALUE, false);
        this.engine_id = engines.Begin();


        this.tracer = Tasks_Road_TownTracer(this.town_id, this.cargo_id, 100);
        this.PushTask(this.tracer);

        state = PICK_STATIONS;
        return true;
    }

    function PickStations(){
        this.tracer.matches.Valuate(Tile.GetCargoAcceptance, this.cargo_id, 1, 1, 3);
        this.owned = AIList();
        owned.AddList(this.tracer.stations);
        owned.Valuate(Tile.GetOwner);
        owned.KeepValue(AICompany.ResolveCompanyID(AICompany.COMPANY_SELF));

        local limit = 1;
        do {
            Log.Info("Attempt #" + limit);

            local others = AIList();
            others.AddList(owned);
            
            local stations = AIList();
            stations.AddList(this.tracer.matches);
            stations.RemoveBelowValue(40);

            local start = Lists.RandPriority(stations);
            stations.RemoveItem(start);
            

            this.selected = AIList();
            this.selected.AddItem(start, 0);
            others.AddItem(start, 0);

            while(stations.Count() > 0){
                stations.Valuate(GetDistance, others);
                stations.Sort(List.SORT_BY_VALUE, true);
                stations.RemoveBelowValue(8);

                if(stations.Count() <= 0)
                    break;

                local next = stations.Begin();
                stations.RemoveItem(next);
                this.selected.AddItem(next, 0);
                others.AddItem(next, 0);
            }
        }while(limit++ < 5 && this.selected.Count() < 2);

        if(this.selected.Count() < 2){
            Log.Error("Failed to find enough station spots in " + Town.GetName(this.town_id));
            // TODO mark town is not suited, and disfavor cargo and build preference
            return false;
        }

        local spots = AIList();
        spots.AddList(this.selected);
        
        if(spots.Count() > this.max_stations){
            spots.Valuate(GetValue, this.cargo_id);
            spots.Sort(List.SORT_BY_VALUE, false);
            spots.RemoveBottom(spots.Count() - this.max_stations);
        }

        Log.Info("Selected " + (this.selected.Count()) + " station location to build");

        this.builder = Tasks_Road_BuildTownStations(this.budget_id, this.funds_id, this.cargo_id, this.town_id, spots, this.tracer.empties);
        this.PushTask(this.builder);

        state = PREP_VEHICLES;
        return true;
    }

    function GetValue(index, cargo_id){
        return Tile.GetCargoAcceptance(index, cargo_id, 1, 1, 3) * Tile.GetCargoProduction(index, cargo_id, 1, 1, 3);
    }

    function GetDistance(index, list){
        local min = 10000;
        
        local x = Tile.GetX(index);
        local y = Tile.GetY(index);

        foreach(tile, dummy in list){
            local dx = abs(Tile.GetX(tile) - x);
            local dy = abs(Tile.GetY(tile) - y);

            if(max(dx, dy) < min)
                min = max(dx, dy);
        }

        return min;
    }

    function PrepVehicles(){
        queue = [];
        foreach(station_tile, _ in this.builder.stations)
            queue.push(station_tile);

        state = SELECT_STATION;
        return SelectStation();
    }

    function SelectStation(){
        this.current_station = queue.pop();

        state = BUY_VEHICLES;
        return BuyVehicles();
    }

    function BuyVehicles(){
        local cost = Engine.GetPrice(this.engine_id) * 1.2;
        if(Budget.GetBudgetAmount(this.budget_id) < cost){
            Log.Warning("Budget '" + Budget.GetName(this.budget_id) + "' not sufficient");
            return this.Wait(30);
        }else if(!Budget.Withdraw(this.budget_id, cost)){
            Log.Warning("Failed to withdraw money for engine need " + Finance.FormatMoney(cost) + " available "+ Finance.FormatMoney(Budget.GetBudgetAmount(this.budget_id)));
            return this.Wait(3);            
        }

        local depot_tile = this.builder.stations.GetValue(this.current_station);
        
        Log.Info("Building vehicle");
        local vehicle_id = Vehicle.BuildVehicle(depot_tile, this.engine_id);
        AIOrder.AppendOrder(vehicle_id, this.current_station, AIOrder.OF_NON_STOP_INTERMEDIATE|AIOrder.OF_FULL_LOAD);

        local destinations = AIList();
        destinations.AddList(this.builder.stations);
        destinations.AddList(owned);
        destinations.RemoveItem(this.current_station);
        destinations.Valuate(Lists.RandRangeItem, 0, 1000);
        destinations.Sort(List.SORT_BY_VALUE, false);
        destinations.KeepTop(2);

        foreach(destination, _ in destinations)
            AIOrder.AppendOrder(vehicle_id, destination, AIOrder.OF_NON_STOP_INTERMEDIATE);
        
        AIOrder.AppendOrder(vehicle_id, depot_tile, AIOrder.OF_GOTO_NEAREST_DEPOT|AIOrder.OF_NON_STOP_INTERMEDIATE);
        AIVehicle.StartStopVehicle(vehicle_id);

        if(queue.len() > 0){
            state = SELECT_STATION;
            return true;
        }

        return false;
    }
 }