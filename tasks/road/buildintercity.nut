/**
 This task tries build a bus or truck station in the given
 town, and tries to connect the towns.

 - Analyze each town for station spots
 - Select up to a max from each town
 - Find path from each town to each town, including found paths as virtual
   roads in next path findings
 - Build each path.
 - Build stations in each town.
 - Add routes from each station to a station of the other towns.
 */
 class Tasks_Road_BuildInterCity extends Task {
	static INITIALIZE		= 0x0;
	static PICK_STATIONS    = 0x2;
    static PREP_FIND        = 0x3;
    static FIND_STEP        = 0x4;
    static BUILD_PATH       = 0x6;
    static BUILD_STATIONS   = 0x7;
    static PREP_VEHICLES    = 0x8;
    static SELECT_STATION   = 0x9;
    static BUY_VEHICLES     = 0xA;
    static FINALIZE         = 0xB;

	state = 0;
    budget_id = 0;
    cargo_id = 0;
    town_ids = 0;
    max_stations = 0;

    engine_id = 0;
    queue = null;
    current_id = 0;
    tracers = null;
    spots = null;
    paths = null;

    virtual = null;

    finder = null;
    
	constructor(budget_id, cargo_id, town_ids, max_stations){
        this.budget_id = budget_id;
        this.cargo_id = cargo_id;
        this.town_ids = town_ids;
        this.max_stations = max_stations;
        
        this.tracers = {};
        this.spots = {};
        this.paths = {};
        this.virtual = AIList();

		state = INITIALIZE;
	}

    function GetName(){
        return "Road_BuildInterCity";
    }

    function Run(){
        switch(state){
            case INITIALIZE: return Initialize();
            case PICK_STATIONS: return PickStations();
            case PREP_FIND: return PrepareFind();
            case FIND_STEP: return FindStep();
            case BUILD_PATH: return BuildPath();
            case BUILD_STATIONS: return BuildStations();
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

        this.queue = clone this.town_ids;

        state = PICK_STATIONS;
        return FindStations();
    }

    function FindStations(){
        if(this.queue.len() <= 0){
            this.queue = clone this.town_ids;
            state = PREP_FIND;
            return true;
        }

        this.current_id = this.queue.pop();

        Log.Info("Inspecting " +  Town.GetName(this.current_id) + " for spots to place stations");

        this.tracers[this.current_id] <- Tasks_Road_TownTracer(this.current_id, this.cargo_id, 100);
        this.PushTask(this.tracers[this.current_id]);
        return true;
    }

    function PickStations(){
        this.tracers[this.current_id].matches.Count();

        local spots = this.tracers[this.current_id].GetSpots(40, 5, 1, this.max_stations);
        if(spots == false){
            Log.Error("Failed to find enough stations spots in " + Town.GetName(this.current_id));
            // TODO mark town is not suited, and disfavor cargo and build preference
            return false;
        }

        this.spots[this.current_id] <- spots;

        Log.Info("Selected " + (spots.Count()) + " station locations to build in " +  Town.GetName(this.current_id));

        return FindStations();
    }

    function PrepareFind(){
        if(this.queue.len() <= 0){
            this.queue = clone this.town_ids;
            state = BUILD_PATH;
            return true;
        }

        this.current_id = this.queue.pop();

        this.finder = RoadPathFinder();
        //this.finder.debug = true;

        foreach(tile, _ in this.spots[this.current_id]){
            local adjacents = AITileList();
            adjacents.AddTile(tile - AIMap.GetTileIndex(1,0));
            adjacents.AddTile(tile - AIMap.GetTileIndex(0,1));
            adjacents.AddTile(tile - AIMap.GetTileIndex(-1,0));
            adjacents.AddTile(tile - AIMap.GetTileIndex(0,-1));
            adjacents.Valuate(Road.AreRoadTilesConnected, tile);
            adjacents.KeepValue(1);

            foreach(adjacent, _ in adjacents)
                this.finder.AddStartPoint(adjacent, tile, 0);
        }

        foreach(town_id, spots in this.spots){
            if(town_id == this.current_id)
                continue;

            foreach(tile, _ in spots)
                this.finder.AddEndPoint(tile, 0);
            
            break;
        }

        this.finder.AddVirtual(this.virtual);

        this.finder.Init();
        state = FIND_STEP;
        return true;
    }

    function FindStep(){
        local limit = 50000;

        this.finder.BeginStep();

        while(limit-- > 0 && finder.Step());

        finder.signs.Clean();

        local path = this.finder.GetPath();
        this.paths[this.current_id] <- path;

        foreach(tile in path)
            this.virtual.AddItem(tile, 0);

        state = PREP_FIND;
        return true;
    }

    function BuildPath(){
        foreach(path in this.paths){
            if(path.len() <= 0)
                continue;

            local builder = Tasks_RoadPathBuilder(Road.ROADTYPE_ROAD);
            builder.Append(path);

            this.EnqueueTask(builder);
        }
        
        state = BUILD_STATIONS;
        return true;
    }

    function BuildStations(){
        return false;
    }
 }