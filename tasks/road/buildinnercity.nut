/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Tasks_Road_BuildInnerCity extends Task {
	static INITIALIZE		= 0;
    static PREP_VEHICLES    = 1;
    static BUY_VEHICLES     = 2;
    static FINALIZE         = 5;

	state = 0;
    budget_id = null;
    funds_id = null;
    cargo_id = null;
    town_id = null;
    max_stations = 0;

    engine_id = null;
    builder = null;
    queue = null;
    
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
            case PREP_VEHICLES: return PrepVehicles();
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

        this.builder = Tasks_Road_BuildTownStations(this.budget_id, this.funds_id, this.cargo_id, this.town_id, this.max_stations);
        this.PushTask(this.builder);
        this.builder.Run();

        state = PREP_VEHICLES;
        return true;
    }

    function PrepVehicles(){
        queue = [];
        foreach(station_tile, _ in this.builder.stations)
            queue.push(station_tile);

        state = BUY_VEHICLES;
        return BuyVehicles();
    }

    function BuyVehicles(){
        local station_tile = queue.pop();

        local cost = Engine.GetPrice(this.engine_id) * 1.2;
        if(!Budget.Take(this.budget_id, cost)){
            Budget.Request(this.budget_id, cost);
            Log.Warning("Waiting for money ENGINE");
            return this.Wait(3);
        }

        local depot_tile = this.builder.stations.GetValue(station_tile);
        
        Log.Info("Building vehicle");
        local vehicle_id = Vehicle.BuildVehicle(depot_tile, this.engine_id);
        AIOrder.AppendOrder(vehicle_id, station_tile, AIOrder.OF_NON_STOP_INTERMEDIATE|AIOrder.OF_FULL_LOAD);

        local destinations = AIList();
        destinations.AddList(this.builder.stations);
        destinations.RemoveItem(station_tile);
        destinations.Valuate(Lists.RandRangeItem, 0, 1000);
        destinations.Sort(List.SORT_BY_VALUE, false);
        destinations.KeepTop(2);

        foreach(destination, _ in destinations)
            AIOrder.AppendOrder(vehicle_id, destination, AIOrder.OF_NON_STOP_INTERMEDIATE);
        
        AIOrder.AppendOrder(vehicle_id, depot_tile, AIOrder.OF_GOTO_NEAREST_DEPOT|AIOrder.OF_NON_STOP_INTERMEDIATE);
        AIVehicle.StartStopVehicle(vehicle_id);

        return queue.len() > 0;
    }
 }