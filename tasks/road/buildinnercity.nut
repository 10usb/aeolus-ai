/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Tasks_Road_BuildInnerCity extends Task {
	static INITIALIZE		= 0;
	static PICK_STATIONS    = 1;
    static BUILD_STATIONS   = 2;
    static BUILD_DEPOTS     = 3;
    static BUY_VEHICLES     = 4;
    static FINALIZE         = 5;

	state = 0;
    budget_id = null;
    funds_id = null;
    cargo_id = null;
    town_id = null;
    max_stations = 0;
    tracer = null;

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
        return "Road_BuildInnerCity";
    }

    function Run(){
        switch(state){
            case INITIALIZE: return Initialize();
            case PICK_STATIONS: return PickStations();
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

        foreach(tile, accept in spots){
            BuildDriveThroughRoadStation(tile);
        }

        // foreach(tile, _ in this.tracer.empties){
        //     this.signs.Build(tile, "DEPOT");
        // }

        return false;
    }

    function BuildDriveThroughRoadStation(tile) {
        local cost = Road.GetBuildCost(Road.ROADTYPE_ROAD, Road.BT_BUS_STOP) * 1.2;
        if(!Budget.Take(budget_id, cost)){
            Budget.Request(budget_id, cost);
            Log.Warning("Waiting for money STATION");
            return this.Wait(3);
        }

        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);
        return Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)
            || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW);
    }
 }