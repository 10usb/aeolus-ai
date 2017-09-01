class MapTile {
}

function MapTile::GetAverageIndex(tiles){
	local x = 0;
	local y = 0;

	if(typeof tiles == "array"){
		foreach(tile in tiles){
			x+= AIMap.GetTileX(tile);
			y+= AIMap.GetTileY(tile);
		}
		return AIMap.GetTileIndex(x / tiles.len(), y / tiles.len());
	}

	foreach(tile, dummy in tiles){
		x+= AIMap.GetTileX(tile);
		y+= AIMap.GetTileY(tile);
	}
	return AIMap.GetTileIndex(x / tiles.Count(), y / tiles.Count());
}

function MapTile::GetDirection(from, to){
	local x = AIMap.GetTileX(to) - AIMap.GetTileX(from);
	local y = AIMap.GetTileY(to) - AIMap.GetTileY(from);

	if(x==1){
		if(y==0) return AITile.SLOPE_SW;
	}else if(x==-1){
		if(y==0) return AITile.SLOPE_NE;
	}else if(x==0){
		if(y==1){
			return AITile.SLOPE_SE;
		}else if(y==-1){
			return AITile.SLOPE_NW;
		}
	}

	throw("Tiles not next to each other");
}