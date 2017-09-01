class MapPoint {
	from	= null;
	to		= null;
}

function MapPoint::Print(prefix = "p:"){
	AISign.BuildSign(this.from, prefix + "from[" + AIMap.GetTileX(this.from) + "," + AIMap.GetTileY(this.from) + "]");
	AISign.BuildSign(this.to, prefix + "to[" + AIMap.GetTileX(this.to) + "," + AIMap.GetTileY(this.to) + "]");
}

function MapPoint::GetMinHeight(){
	return MapPoint.GetMinHeightAt(this.from, this.to);
}

function MapPoint::GetMaxHeight(){
	return MapPoint.GetMaxHeightAt(this.from, this.to);
}

function MapPoint::GetMinHeightAt(from, to){
	throw("Not implimented");
}

function MapPoint::GetMaxHeightAt(from, to){
	if(AIMap.DistanceManhattan (from, to)!=1) throw("Tiles to far from each other");

	local x	= AIMap.GetTileX(to) - AIMap.GetTileX(from);
	local y	= AIMap.GetTileY(to) - AIMap.GetTileY(from);

	if(x!=0){
		local index = x > 0 ? from : to;
		switch(AITile.GetSlope(index)){
			case AITile.SLOPE_FLAT: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_W: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_S: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_E: return AITile.GetMinHeight(index);
			case AITile.SLOPE_N: return AITile.GetMinHeight(index);
			case AITile.SLOPE_STEEP: throw("Not implimented");
			case AITile.SLOPE_NW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_SW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_SE: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_NE: return AITile.GetMinHeight(index);
			case AITile.SLOPE_EW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_NS: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_ELEVATED: throw("Not implimented");
			case AITile.SLOPE_NWS: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_WSE: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_SEN: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_ENW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_W: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_S: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_E: return AITile.GetMinHeight(index) + 1;
			case AITile.SLOPE_STEEP_N: return AITile.GetMinHeight(index) + 1;
			case AITile.SLOPE_INVALID: throw("Not implimented");
		}
	}else{
		local index = y > 0 ? from : to;
		switch(AITile.GetSlope(index)){
			case AITile.SLOPE_FLAT: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_W: return AITile.GetMinHeight(index);
			case AITile.SLOPE_S: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_E: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_N: return AITile.GetMinHeight(index);
			case AITile.SLOPE_STEEP: throw("Not implimented");
			case AITile.SLOPE_NW: return AITile.GetMinHeight(index);
			case AITile.SLOPE_SW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_SE: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_NE: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_EW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_NS: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_ELEVATED: throw("Not implimented");
			case AITile.SLOPE_NWS: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_WSE: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_SEN: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_ENW: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_W: return AITile.GetMinHeight(index) + 1;
			case AITile.SLOPE_STEEP_S: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_E: return AITile.GetMaxHeight(index);
			case AITile.SLOPE_STEEP_N: return AITile.GetMinHeight(index) + 1;
			case AITile.SLOPE_INVALID: throw("Not implimented");
		}
	}
	throw("Not implimented");
}