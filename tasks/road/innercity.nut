/**
 * This task only tries to connect busses and post-trucks
 * within the border of a city
 */
class Road_InnerCity extends Task {
	static INITIALIZE			= 0;
    static SELECT_TOWN          = 1;
	static BUILD_STATIONS       = 2;
	static BUILD_DEPOT          = 3;
	static BUILD_VEHICLE        = 4;

	state = 0;
    towns = null;
    town_id = 0;
    stations = null;
    depot_tile = null;
    task = null;

	constructor(){
		this.state = INITIALIZE;
	}

    function GetName(){
        return "Road_InnerCity";
    }

    function Run(){
        switch(state){
            case INITIALIZE: return Initialize();
            case SELECT_TOWN: return SelectTown();
            case BUILD_STATIONS: return BuildStation();
            case BUILD_DEPOT: return BuildDepot();
            case BUILD_VEHICLE: return BuildVehicle();
        }

        return false;
    }

    function Initialize(){
        // Select Town
        towns = AITownList();
        towns.Valuate(Town.IsCity);
        towns.KeepValue(1);
        towns.Valuate(Town.GetPopulation);
        towns.Sort(List.SORT_BY_VALUE, false);

        state = SELECT_TOWN;
        return true;
    }

    function SelectTown(){
        if(towns.Count() <= 0){
            state = INITIALIZE;
            return this.Sleep(100);
        }
        town_id = Lists.RandPriority(towns);
        towns.RemoveItem(town_id);


        local tiles = Town.GetTiles(town_id, true, 2);
        tiles.Valuate(Road.IsRoadStationTile);
        tiles.KeepValue(1);
        tiles.Valuate(Station.GetStationID);

        local temp = Lists.Flip(tiles);
        temp.Valuate(Station.IsValidStation);
        temp.KeepValue(1);
        if(temp.Count() > 0){
            Log.Warning("Town already populated: " + Town.GetName(town_id));
            return true;
        }

        Log.Info("Selected town: " + Town.GetName(town_id));
        stations = [];

        task = Road_BuildTownStation(town_id, Cargo.GetPassengerId());
        this.PushTask(task);

        state = BUILD_STATIONS;
        return true;
    }

    function BuildStation(){
        if(task.depot_tile != null)
            depot_tile = task.depot_tile;

        // If succesfull build try an other one
        if(task.station_tile != null){
            stations.push(task.station_tile);
            task = Road_BuildTownStation(town_id, Cargo.GetPassengerId());
            this.PushTask(task);
            return true;
        }

        if(stations.len() < 2){
            Log.Warning("Failed to build enough stations in " + Town.GetName(town_id));

            foreach(tile in stations){
                AIRoad.RemoveRoadStation(tile);
            }
            
            state = SELECT_TOWN;
            return true;
        }

        state = BUILD_VEHICLE;
        return true;
    }

    function BuildVehicle(){
        local engines = AIEngineList(AIVehicle.VT_ROAD);
        engines.Valuate(Engine.GetCargoType)
        engines.KeepValue(Cargo.GetPassengerId());
        engines.Sort(AIList.SORT_BY_VALUE, false);
        local engine_id = engines.Begin();

        local station_list = List();
        foreach(station in stations){
            station_list.AddItem(station, 0);
        }

        local queue = TaskQueue();

        foreach(station in stations){
            local destinations = List();
            destinations.AddList(station_list);
            destinations.RemoveItem(station);

            local task = Road_BuildVehicle(
                engine_id,
                depot_tile,
                station,
                destinations
            );
            queue.EnqueueTask(task);
        }

        this.PushTask(queue);
        
        state = SELECT_TOWN;
        return true;
    }
}