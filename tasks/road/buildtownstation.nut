/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Road_BuildTownStation extends Task {
	static DETECT_OTHERS		= 0;
    static FIND_POTENTIAL       = 1;
	static BUILD_STATION        = 2;
	static ENSURE_DEPOT         = 3;

	state = 0;
    town_id = null;
    cargo_id = null;
    station_tile = null;

    town_tiles = null;
    station_tiles = null;
    tiles = null;

	constructor(town_id, cargo_id){
        this.town_id = town_id
        this.cargo_id = cargo_id;
        this.station_tile = null;
		this.state = DETECT_OTHERS;
	}

    function GetName(){
        return "Road_BuildTownStation";
    }

    function Run(){
        switch(state){
            case DETECT_OTHERS: return DetectOthers();
            case FIND_POTENTIAL: return FindPotential();
            case BUILD_STATION: return BuildStation();
            case ENSURE_DEPOT: return EnsureDepot();
        }

        return false;
    }

    /**
     Finds other similar bus/truck stations tiles
    */
    function DetectOthers(){
        Log.Info("Trying to build station in " + Town.GetName(town_id));

        town_tiles = Town.GetTiles(town_id, true, 2);
        Log.Info("Build list of town tiles");

        station_tiles = List();
        station_tiles.AddList(town_tiles);
        station_tiles.Valuate(Road.IsRoadStationTile);
        station_tiles.RemoveValue(0);

        if(station_tiles.Count() > 0)
            Log.Info("Found " + station_tiles.Count() + " other station tiles in this town");

        state = FIND_POTENTIAL;
        return true;
    }

    /**
     Find tiles that support a minimum production and/or acceptance
     of the specified cargo. And are of reasonable distance to
     other stations
    */
    function FindPotential(){
        tiles = List();
        tiles.AddList(town_tiles);
        tiles.Valuate(Road.IsRoadTile);
        tiles.RemoveValue(0);

        if(station_tiles.Count() > 0){
            Log.Info("Searching for tiles not close to other stations");
            tiles.Valuate(Road_BuildTownStation.GetMinDistance, station_tiles);
            tiles.KeepAboveValue(7);
        }

        tiles.Valuate(Tile.GetCargoAcceptance, Cargo.GetPassengerId(), 1, 1, 3);
        tiles.RemoveBelowValue(40);
        tiles.Sort(List.SORT_BY_VALUE, false);
	    tiles.KeepTop(Math.max(5, tiles.Count() / 4));
        tiles.Valuate(Lists.RandRangeItem, 1, 1000);
        tiles.Sort(List.SORT_BY_VALUE, false);
        Log.Info("Found " + tiles.Count() + " potential tiles");
        
        state = BUILD_STATION;
        return true;
    }

    function GetMinDistance(tile, stations_tiles){
        local tiles = List();
        tiles.AddList(stations_tiles);
        // This should be min(deltaX, deltaY)
        tiles.Valuate(Tile.GetDistanceManhattanToTile, tile);
        tiles.Sort(List.SORT_BY_VALUE, true);
        return tiles.GetValue(tiles.Begin());
    }

    /**
     Attempt to build a station on one of the potential tiles.
    */
    function BuildStation(){
        local price = Road.GetBuildCost(Road.ROADTYPE_ROAD, Road.BT_BUS_STOP) * 1.2;
        local available = Finance.GetAvailableMoney();

        if(price > available){
            Log.Warning("Waiting for money STATION");
            return this.Wait(3);
        }

        if(!Finance.GetMoney(price))
            return true;

        foreach(tile, _ in tiles){
            if(this.BuildDriveThroughRoadStation(tile)){
                station_tile = tile;
                state = ENSURE_DEPOT;
                return true;
            }
        }

        return false;
    }

    function BuildDriveThroughRoadStation(tile) {
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);
        return Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)
            || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW);
    }

    /**
     Tries to find a spot for a depot to build. And checks if there
     isn't one closer by.
    */
    function EnsureDepot(){
        return false;
    }
}