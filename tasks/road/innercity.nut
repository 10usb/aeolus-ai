/**
 * This task only tries to connect busses and post-trucks
 * within the border of a city
 */
 class Road_InnerCity extends Task {
	constructor(){
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);
	}

    function GetName(){
        return "Road_InnerCity"
    }

    function Run(){
        // Select Town
        local towns = AITownList();
        towns.Valuate(Town.IsCity);
        towns.KeepValue(1);
        towns.Valuate(Town.GetPopulation);
        towns.Sort(List.SORT_BY_VALUE, false);
        //local town_id = Lists.RandPriority(towns);

        foreach(town_id, _ in towns){
            this.Build(town_id);
        }

        return false;
    }

    function Build(town_id){
        Log.Info("Selected town: " + Town.GetName(town_id));
        
        // Build first station
        local tiles = Town.GetTiles(town_id, true);
        tiles.Valuate(Road.IsRoadTile);
        tiles.RemoveValue(0);
        tiles.Valuate(Tile.GetCargoAcceptance, Cargo.GetPassengerId(), 1, 1, 3);
        //tiles.RemoveBelowValue(10);
        tiles.Sort(List.SORT_BY_VALUE, false);
	    tiles.KeepTop(Math.max(5, tiles.Count() / 4));
        tiles.Valuate(Lists.RandRangeItem, 1, 1000);
        tiles.Sort(List.SORT_BY_VALUE, false);

        local firstStation = null;
        foreach(tile, _ in tiles){
            if(this.BuildDriveThroughRoadStation(tile)){
                firstStation = tile;
                break;
            }
        }

        if (firstStation == null) {
            Log.Warning("First station failed, aborting");
            return true;
        }

        // Build second station
        tiles = Town.GetTiles(town_id, true);
        tiles.Valuate(Road.IsRoadTile);
        tiles.RemoveValue(0);
        // This should be min(deltaX, deltaY)
        tiles.Valuate(AIMap.DistanceManhattan, firstStation);
        tiles.KeepAboveValue(7);

        tiles.Valuate(Tile.GetCargoAcceptance, Cargo.GetPassengerId(), 1, 1, 3);
        //tiles.RemoveBelowValue(10);
        tiles.Sort(List.SORT_BY_VALUE, false);
	    tiles.KeepTop(Math.max(5, tiles.Count() / 4));
        tiles.Valuate(Lists.RandRangeItem, 1, 1000);
        tiles.Sort(List.SORT_BY_VALUE, false);

        local secondStation = null;
        foreach(tile, _ in tiles){
            if(this.BuildDriveThroughRoadStation(tile)){
                secondStation = tile;
                break;
            }
            // if (Road.IsRoadStationTile(tile)) {
            //     secondStation = tile;
            //     break;
            // }
        }

        if (secondStation == null) {
            Log.Warning("Second station failed, aborting");
            Road.RemoveRoadStation(firstStation);
            return true;
        }

        // Build depot
        // Add bus
        return true;
    }

    function BuildDriveThroughRoadStation(tile) {
        return Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)
            || Road.BuildDriveThroughRoadStation(tile, tile + AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW);
    }
}