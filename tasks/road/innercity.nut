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
        // If succesfull build try an other one
        if(task.station_tile != null){
            stations.push(task.station_tile);
            task = Road_BuildTownStation(town_id, Cargo.GetPassengerId());
            this.PushTask(task);
            return true;
        }

        state = BUILD_DEPOT;
        return true;
    }

    function BuildDriveThroughRoadStation(tile) {
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);
        return Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)
            || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW);
    }

    function BuildDepot(){
        if(stations.len() < 2){
            Log.Warning("Failed to build enough stations in " + Town.GetName(town_id));

            foreach(tile in stations){
                AIRoad.RemoveRoadStation(tile);
            }
            
            state = SELECT_TOWN;
            return true;
        }

        
        local cost = Road.GetBuildCost(Road.ROADTYPE_ROAD, Road.BT_DEPOT) * 1.2;
        if(!Finance.GetMoney(cost)){
            Log.Warning("Waiting for money DEPOT");
            return this.Wait(3);
        }

        local tiles = Town.GetTiles(town_id, true, 2);
        tiles.Valuate(Tile.IsBuildableRectangle, 2, 2);
        tiles.KeepValue(1);
        tiles.Valuate(Road_InnerCity.RoadAccess);
        tiles.KeepAboveValue(0);
        tiles.Valuate(Tile.GetDistanceSquareToTile, Town.GetLocation(town_id));
        tiles.Sort(AIList.SORT_BY_VALUE, true);
        Log.Info("Found " + tiles.Count() + " potential tiles for a depot");

        local tile;
        do {
            if(tiles.Count() <= 0){
                Log.Warning("Failed to build depot in " + Town.GetName(town_id));

                foreach(tile in stations){
                    AIRoad.RemoveRoadStation(tile);
                }
                
                state = SELECT_TOWN;
                return true;
            }
            tile = tiles.Begin();
            tiles.RemoveTop(1);
        }while(!TryBuildDepot(tile));

        depot_tile = tile;
        state = BUILD_VEHICLE;
        return true;
    }

    function RoadAccess(tile){
        local tiles = AITileList();
        tiles.AddRectangle(Tile.GetTranslatedIndex(tile, 0, -1), Tile.GetTranslatedIndex(tile, 0, 1));
        tiles.AddRectangle(Tile.GetTranslatedIndex(tile, -1, 0), Tile.GetTranslatedIndex(tile, 1, 0));
        tiles.Valuate(AIRoad.IsRoadTile);
        return Lists.GetSum(tiles);
    }

    function TryBuildDepot(tile){
        if(Tile.GetSlope(tile) != Tile.SLOPE_FLAT){
            local matrix = MapMatrix();
            matrix.AddRectangle(tile, 1, 1);
            if(!matrix.MakeLevel()) return false;
        }

        local tiles = AITileList();
        tiles.AddRectangle(Tile.GetTranslatedIndex(tile, 0, -1), Tile.GetTranslatedIndex(tile, 0, 1));
        tiles.AddRectangle(Tile.GetTranslatedIndex(tile, -1, 0), Tile.GetTranslatedIndex(tile, 1, 0));
        tiles.Valuate(AIRoad.IsRoadTile);

        foreach(front, _ in tiles){
            if(!Road.BuildRoadDepot(tile, front))
                continue;

            Road.BuildRoad(tile, front);

            if(Road.AreRoadTilesConnected(tile, front))
                return true;
        }

        return false;
    }

    function BuildVehicle(){
        local engines = AIEngineList(AIVehicle.VT_ROAD);
        engines.Valuate(Engine.GetCargoType)
        engines.KeepValue(Cargo.GetPassengerId());
        engines.Sort(AIList.SORT_BY_VALUE, false);
        local engine_id = engines.Begin();

        local cost = Engine.GetPrice(engine_id) * 1.2;
        if(!Finance.GetMoney(cost)){
            Log.Warning("Waiting for money ENGINE");
            return this.Wait(3);
        }

        Log.Info("Building vehicle");
        local vehicle_id = Vehicle.BuildVehicle(depot_tile, engine_id);
        foreach(station in stations){
            AIOrder.AppendOrder(vehicle_id, station, AIOrder.OF_NONE);
        }
        AIVehicle.StartStopVehicle(vehicle_id);
        
        state = SELECT_TOWN;
        return true;
    }
}