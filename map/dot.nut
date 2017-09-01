class MapDot {
	index	= null;
	height	= null;
	locked	= null;

	constructor(index){
		this.index	= index;
		this.height	= this.getCurrentHeight();
		this.locked	= !AITile.IsBuildableRectangle(MapMatrix.Translate(index, -1, -1), 1, 1);
	}
}

function MapDot::getDifferance(){
	return this.height - this.getCurrentHeight();
}

function MapDot::getCurrentHeight(){
	return this.getHeight(this.index);
}

function MapDot::getHeight(index){
	switch(AITile.GetSlope(index)){
		case AITile.SLOPE_FLAT: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_W: return AITile.GetMinHeight(index);
		case AITile.SLOPE_S: return AITile.GetMinHeight(index);
		case AITile.SLOPE_E: return AITile.GetMinHeight(index);
		case AITile.SLOPE_N: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_STEEP: throw("Not implimented");
		case AITile.SLOPE_NW: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_SW: return AITile.GetMinHeight(index);
		case AITile.SLOPE_SE: return AITile.GetMinHeight(index);
		case AITile.SLOPE_NE: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_EW: return AITile.GetMinHeight(index);
		case AITile.SLOPE_NS: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_ELEVATED: throw("Not implimented");
		case AITile.SLOPE_NWS: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_WSE: return AITile.GetMinHeight(index);
		case AITile.SLOPE_SEN: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_ENW: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_STEEP_W: return AITile.GetMinHeight(index) + 1;
		case AITile.SLOPE_STEEP_S: return AITile.GetMinHeight(index);
		case AITile.SLOPE_STEEP_E: return AITile.GetMinHeight(index) + 1;
		case AITile.SLOPE_STEEP_N: return AITile.GetMaxHeight(index);
		case AITile.SLOPE_INVALID: throw("Not implimented");
	}

	throw("Not implimented");
}