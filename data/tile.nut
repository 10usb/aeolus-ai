class Tile extends AITile {
}

// Copy these tile related method from Map to the Tile class for consistancy
Tile.IsValidTile <- AIMap.IsValidTile;
Tile.GetIndex <- AIMap.GetTileIndex;
Tile.GetX <- AIMap.GetTileX;
Tile.GetY <- AIMap.GetTileY;

function Tile::GetTranslatedIndex(index, x, y){
	return AIMap.GetTileIndex(
            AIMap.GetTileX(index) + x,
            AIMap.GetTileY(index) + y
        );
}

function Tile::IsCrossable(index){
    return AIRoad.IsRoadTile(index) || AIRail.IsRailTile(index) || Tile.IsWaterTile(index);
}

function Tile::GetDirection(from, to){
	local x = AIMap.GetTileX(to) - AIMap.GetTileX(from);
	local y = AIMap.GetTileY(to) - AIMap.GetTileY(from);

	if(x > 0){
		if(y == 0) return AITile.SLOPE_SW;
        throw("Tiles not next to each other");
	}

    if(x < 0){
		if(y == 0) return AITile.SLOPE_NE;
        throw("Tiles not next to each other");
	}
    
    // Now x must be 0
    if(x != 0) throw("Tiles not next to each other");

    // Check the y
    if(y > 0) return AITile.SLOPE_SE;
    if(y < 0) return AITile.SLOPE_NW;

	throw("Tiles not next to each other");
}

function Tile::GetSlopeName(slope){
	switch(slope){
		case Tile.SLOPE_NE: return "NE";
		case Tile.SLOPE_NW: return "NW";
		case Tile.SLOPE_SW: return "SW";
		case Tile.SLOPE_SE: return "SE";
	}
	throw("Unknown Slope");
}

function Tile::GetSlopeTileIndex(index, slope){
    local x = AIMap.GetTileX(index);
    local y = AIMap.GetTileY(index);

	switch(slope){
		case Tile.SLOPE_NE: return AIMap.GetTileIndex(x - 1, y);
		case Tile.SLOPE_NW: return AIMap.GetTileIndex(x, y - 1);
		case Tile.SLOPE_SW: return AIMap.GetTileIndex(x + 1, y);
		case Tile.SLOPE_SE: return AIMap.GetTileIndex(x, y + 1);
	}
	throw("Unknown Slope");
}