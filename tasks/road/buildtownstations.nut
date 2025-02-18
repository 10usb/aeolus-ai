/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Tasks_Road_BuildTownStations extends Task {
	static INITIALIZE		= 0;
	static PICK_STATIONS    = 1;
    static BUILD_STATIONS   = 2;
    static PREP_DEPOTS      = 3;
    static BUILD_DEPOTS     = 4;
	static FINALIZE         = 5;

	state = 0;

    budget_id = null;
    funds_id = null;
    cargo_id = null;
    town_id = null;
    min = 0;
    max = 0;
    tracer = null;
    queue = null;
    stations = null;
    vehicleType = null;
    depots = null;

    signs = null;

	constructor(budget_id, funds_id, cargo_id, town_id, min, max){
        this.budget_id = budget_id;
        this.funds_id = funds_id;
        this.cargo_id = cargo_id;
        this.town_id = town_id
        this.min = min;
        this.max = max;

		state = INITIALIZE;
	}

    function GetName(){
        return "Road_BuildTownStations";
    }

    function Run(){
        switch(state){
            case INITIALIZE: return Initialize();
            case PICK_STATIONS: return PickStations();
            case BUILD_STATIONS: return BuildStations();
            case PREP_DEPOTS: return PrepDepots();
            case BUILD_DEPOTS: return BuildDepots();
            case FINALIZE: return Finalize();
        }
        return false;
    }

    function Initialize(){
        this.signs = Signs();

        this.tracer = Tasks_Road_TownTracer(this.town_id, this.cargo_id, 100);
        this.PushTask(this.tracer);

        this.vehicleType =  Road.GetRoadVehicleTypeForCargo(this.cargo_id);

        state = PICK_STATIONS;
        return true;
    }


    function PickStations(){
        if(this.tracer.selected.Count() < this.min){
            Log.Error("Failed to find enough station spots in " + Town.GetName(this.town_id));
            // TODO mark town is not suited, and disfavor cargo and build preference
            return false;
        }

        local spots = AIList();
        spots.AddList(this.tracer.selected);
        
        if(spots.Count() > this.max){
            spots.Valuate(Tile.GetCargoAcceptance, this.cargo_id, 1, 1, 3);
            spots.Sort(List.SORT_BY_VALUE, true);
            spots.RemoveBottom(spots.Count() - this.max);
        }

        Log.Info("Selected " + (this.tracer.selected.Count()) + " station location to build");
        
        this.queue = [];
        foreach(tile, accept in spots){
            this.queue.push(tile);
        }

        this.stations = AIList();

        state = BUILD_STATIONS;
        return true;
    }

    function BuildStations(){
        while(this.queue.len() > 0){
            local tile = this.queue.pop();

            local cost = Road.GetBuildCost(Road.ROADTYPE_ROAD, Road.BT_BUS_STOP) * 1.2;
            if(!Budget.Take(budget_id, cost)){
                Budget.Request(budget_id, cost);
                Log.Warning("Waiting for money STATION");
                return this.Wait(3);
            }

            Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);
            if(Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), this.vehicleType, AIBaseStation.STATION_NEW)
                || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), this.vehicleType, AIBaseStation.STATION_NEW)){
                this.stations.AddItem(tile, 0);
            }else{
                this.signs.Build(tile, "Station");
                Log.Error("Failed to build station [" + Tile.GetX(tile) + "x" + Tile.GetY(tile) + "]");
            }
        }
        
        state = PREP_DEPOTS;
        return true;
    }

    function PrepDepots(){
        queue = [];
        foreach(station_tile, _ in this.stations)
            queue.push(station_tile);

        this.stations.Valuate(this.GetClosestEmpty, this.tracer.empties);
        this.depots = AIList();

        state = BUILD_DEPOTS;
        return BuildDepots();
    }

    function BuildDepots(){
        while(this.queue.len() > 0){
            local cost = Road.GetBuildCost(Road.ROADTYPE_ROAD, Road.BT_DEPOT) * 1.2;
            if(!Budget.Take(budget_id, cost)){
                Budget.Request(budget_id, cost);
                Log.Warning("Waiting for money DEPOT");
                return this.Wait(3);
            }

            local tile = this.queue.pop();
            local depot_tile = this.stations.GetValue(tile);
            local front_tile = null;

			front_tile = Tile.GetTranslatedIndex(depot_tile, 1, 0);
            if(this.BuildDepot(depot_tile, front_tile))
                continue;

			front_tile = Tile.GetTranslatedIndex(depot_tile, -1, 0);
            if(this.BuildDepot(depot_tile, front_tile))
                continue;

			front_tile = Tile.GetTranslatedIndex(depot_tile, 0, 1);
            if(this.BuildDepot(depot_tile, front_tile))
                continue;

			front_tile = Tile.GetTranslatedIndex(depot_tile, 0, -1);
            if(this.BuildDepot(depot_tile, front_tile))
                continue;
            
            Log.Warning("Failed to build depot [" + Tile.GetX(depot_tile) + "x" + Tile.GetY(depot_tile) + "]");
            this.stations.SetValue(tile, 0);
        }

        state = FINALIZE;
        return true;
    }

    function GetClosestEmpty(tile, list){
        list.Valuate(Tile.GetMaxDistance, tile);
        list.KeepAboveValue(3);
        list.Sort(List.SORT_BY_VALUE, true);
        return list.Begin();
    }

	function BuildDepot(depot_tile, front_tile){
        if(!Road.IsRoadTile(front_tile))
            return false;

		if(!Road.BuildRoadDepot(depot_tile, front_tile))
			return false;

		Road.BuildRoad(depot_tile, front_tile);

		if(!Road.AreRoadTilesConnected(depot_tile, front_tile)){
			Road.RemoveRoadDepot(depot_tile);
			return false;
		}

        this.depots.AddItem(depot_tile, front_tile);
        return true;
	}

    function Finalize(){
        local copy = AIList();
        copy.AddList(this.depots);

        this.stations.Valuate(this.GetClosestEmpty, copy);
        return false;
    }
}