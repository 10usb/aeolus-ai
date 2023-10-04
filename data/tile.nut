class Tile extends AITile {
	static AXIS_INVALID = 0;
	static AXIS_X = 1;
	static AXIS_Y = 2;

	static SIDE_NW = 1;
	static SIDE_NE = 2;
	static SIDE_SW = 4;
	static SIDE_SE = 8;
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
    return AIRoad.IsRoadTile(index)
		|| AIRail.IsRailTile(index)
		|| Tile.IsWaterTile(index)
		//|| Tile.IsRiverTile(index)
		|| AIMarine.IsCanalTile(index);
}

function Tile::IsFlat(index){
	return Tile.GetSlope(index) == Tile.SLOPE_FLAT;
}

function Tile::IsFlatRectangle(index, width, height){
	local list = AITileList();
	list.AddRectangle(index, Tile.GetTranslatedIndex(index, width - 1, height - 1));
	list.Valuate(Tile.IsFlat);
	local size = list.Count();
	list.KeepValue(1);
	return list.Count() == size;
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

function Tile::GetDistance(from, to){
	return (sqrt(Tile.GetDistanceSquareToTile(from, to)) + 0.5).tointeger();
}

function Tile::GetAngledIndex(origin, angle, length){
	local rad = angle * PI * 2 / 360;
	local origin_x = Tile.GetX(origin);
	local origin_y = Tile.GetY(origin);
	local offset_x = (cos(rad) * length + 0.5).tointeger();
	local offset_y = (sin(rad) * length + 0.5).tointeger();
	return Tile.GetIndex(origin_x + offset_x, origin_y + offset_y);
}

function Tile::GetAngle(from, towards){
	local ox = Tile.GetX(from);
	local oy = Tile.GetY(from);
	local tx = Tile.GetX(towards);
	local ty = Tile.GetY(towards);
	return atan2(ty - oy, tx - ox) * 360 / (PI * 2);
}

function Tile::GetAxis(slope){
	switch(slope){
		case Tile.SLOPE_NE: return Tile.AXIS_X;
		case Tile.SLOPE_NW: return Tile.AXIS_Y;
		case Tile.SLOPE_SW: return Tile.AXIS_X;
		case Tile.SLOPE_SE: return Tile.AXIS_Y;
	}
	return Tile.AXIS_INVALID;
}

function Tile::GetAxisName(axis){
	switch(axis){
		case Tile.AXIS_INVALID: return "Invalid";
		case Tile.AXIS_X: return "X-axis";
		case Tile.AXIS_Y: return "Y-axis";
	}
	throw("Unknown Slope");
}

function Tile::GetCorners(slope){
	local list = List();

	if((slope & Tile.SLOPE_N) != 0) list.AddItem(Tile.CORNER_N, 0);
	if((slope & Tile.SLOPE_E) != 0) list.AddItem(Tile.CORNER_E, 0);
	if((slope & Tile.SLOPE_S) != 0) list.AddItem(Tile.CORNER_S, 0);
	if((slope & Tile.SLOPE_W) != 0) list.AddItem(Tile.CORNER_E, 0);

	return list;
}
