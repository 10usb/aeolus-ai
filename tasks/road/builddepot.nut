/**
* This task tries build a bus or truck station in a town
* with a reasonable distance to other stations of same type.
*/
class Road_BuildDepot extends Task {
	static FIND_SPOT      	= 0;
	static BUILD_DEPOT      = 1;
	static FAILED      		= 2;

	state = 0;
	station_tile = null;
	queue = null;
	checked_tiles = null;
	front_tile = null;
	depot_tile = null;

	constructor(station_tile){
		this.station_tile = station_tile;
		this.state = FIND_SPOT;

		queue = [];
		queue.push(station_tile);
		checked_tiles = List();
		depot_tile = null;
	}

	function GetName(){
		return "Road_BuildDepots";
	}

	function Run(){
		switch(state){
			case FIND_SPOT: return FindSpot();
			case BUILD_DEPOT: return BuildDepot();
		}

		return false;
	}

	function FindSpot(){
		local test = null;
		local tile = null;

		while(queue.len()){
			tile = queue[0];
			queue.remove(0);

			test = Tile.GetTranslatedIndex(tile, 1, 0);
			if(Tile.IsBuildable(test)) break;
			if(Road.AreRoadTilesConnected(tile, test))queue.push(test);

			test = Tile.GetTranslatedIndex(tile, -1, 0);
			if(Tile.IsBuildable(test)) break;
			if(Road.AreRoadTilesConnected(tile, test)) queue.push(test);

			test = Tile.GetTranslatedIndex(tile, 0, 1);
			if(Tile.IsBuildable(test)) break;
			if(Road.AreRoadTilesConnected(tile, test))queue.push(test);

			test = Tile.GetTranslatedIndex(tile, 0, -1);
			if(Tile.IsBuildable(test)) break;
			if(Road.AreRoadTilesConnected(tile, test))queue.push(test);
		}
		
		front_tile = tile;
		depot_tile = test;
		
		this.state = BUILD_DEPOT;
		return true;
	}

	function BuildDepot(){
		if(depot_tile == null){
			Log.Warning("Failed to build depot")
			return false;
		}
		if(!Road.BuildRoadDepot(depot_tile, front_tile)){
			this.state = FIND_SPOT;
			return true;
		}

		Road.BuildRoad(depot_tile, front_tile);

		if(!Road.AreRoadTilesConnected(depot_tile, front_tile)){
			Road.RemoveRoadDepot(depot_tile);
			this.state = FIND_SPOT;
			return true;
		}

		return false;
	}
}