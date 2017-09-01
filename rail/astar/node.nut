class RailAstarNode {
	index	 	= null;
	towards		= null;
	value		= 0;
	fixed		= false;
}

function RailAstarNode::GetNeighbors(){
	local x			= AIMap.GetTileX(this.index);
	local y			= AIMap.GetTileY(this.index);
	local list		= [];

	list.push(AIMap.GetTileIndex(x - 1, y)); // SLOPE_NE
	list.push(AIMap.GetTileIndex(x, y - 1)); // SLOPE_NW
	list.push(AIMap.GetTileIndex(x + 1, y)); // SLOPE_SW
	list.push(AIMap.GetTileIndex(x, y + 1)); // SLOPE_SE

	return list;
}