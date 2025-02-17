/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Tasks_Road_BuildTownStations extends Task {
	static INITIALIZE		= 0;
	static PICK_STATIONS    = 1;
    static BUILD_STATIONS   = 2;
    static BUILD_DEPOTS     = 3;
	static FINALIZE         = 4;

	state = 0;

    budget_id = null;
    funds_id = null;
    cargo_id = null;
    town_id = null;
    max_stations = 0;
    tracer = null;
    queue = null;
    stations = null;

    signs = null;

	constructor(budget_id, funds_id, cargo_id, town_id, max_stations){
        this.budget_id = budget_id;
        this.funds_id = funds_id;
        this.cargo_id = cargo_id;
        this.town_id = town_id
        this.max_stations = max_stations;

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
            case BUILD_DEPOTS: return BuildDepots();
            case FINALIZE: return Finalize();
        }
        return false;
    }

    function Initialize(){
        this.signs = Signs();

        this.tracer = Tasks_Road_TownTracer(this.town_id, this.cargo_id, 100);
        this.PushTask(this.tracer);

        state = PICK_STATIONS;
        return true;
    }


    function PickStations(){
        if(this.tracer.selected.Count() < 2){
            Log.Error("Failed to find enough station spots in " + Town.GetName(this.town_id));
            // TODO mark town is not suited, and disfavor cargo and build preference
            return false;
        }

        local spots = AIList();
        spots.AddList(this.tracer.selected);
        
        if(spots.Count() > this.max_stations){
            spots.Valuate(Tile.GetCargoAcceptance, this.cargo_id, 1, 1, 3);
            spots.Sort(List.SORT_BY_VALUE, true);
            spots.RemoveBottom(spots.Count() - this.max_stations);
        }
        
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
            if(Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)
                || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)){
                this.stations.AddItem(tile, 0);
            }
        }

        state = BUILD_DEPOTS;
        return true;
    }

    function BuildDepots(){
        this.stations.Valuate(this.GetClosestEmpty, this.tracer.empties);

        foreach(tile, depot_tile in this.stations){
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
            
            this.stations.SetValue(tile, 0);
        }

        state = FINALIZE;
        return true;
    }

    function GetClosestEmpty(tile, list){
        list.Valuate(Tile.GetDistanceManhattanToTile, tile);
        list.KeepAboveValue(2);
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

        return true;
	}

    function Finalize(){
        return false;
    }
}