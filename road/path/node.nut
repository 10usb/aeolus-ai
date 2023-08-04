class RoadPathNode {
    // The tile index
    index	 	= null;
    // The coords
    x	 	    = null; 
    y	 	    = null;
    // The node pointing to
    forerunner  = null;
    // The side pointing to
	towards		= null;
    // Value of this node
	value		= 0;
    // This is an extra value to accelerate the finding 
    extra       = 0;
    // Is it a bridge yes/no
    bridge      = false;
    // Index of the start node it's pointig to
    start      = null;

	constructor(index, forerunner, value){
        this.index	    = index;
		this.x		    = AIMap.GetTileX(index);
		this.y		    = AIMap.GetTileY(index);
		this.forerunner	= forerunner;
        this.value      = value;
        this.extra      = 0;
        this.bridge     = false;
        this.start      = 0;

		if(forerunner){
			this.towards = Tile.GetDirection(this.index, forerunner.index);
		}
	}
}

// Returns only the tiles to wich a rail can be build depending on the slope this tile has
function RoadPathNode::GetCandidates(){
	local list		= AIList();
    local slope = Tile.GetSlope(this.index);

    // If the tile is flat then all direction are posible
    if(slope == Tile.SLOPE_FLAT)
    {
        if(this.towards != Tile.SLOPE_NE) list.AddItem(AIMap.GetTileIndex(this.x - 1, this.y), Tile.SLOPE_NE); // SLOPE_NE
        if(this.towards != Tile.SLOPE_NW) list.AddItem(AIMap.GetTileIndex(this.x, this.y - 1), Tile.SLOPE_NW); // SLOPE_NW
        if(this.towards != Tile.SLOPE_SW) list.AddItem(AIMap.GetTileIndex(this.x + 1, this.y), Tile.SLOPE_SW); // SLOPE_SW
        if(this.towards != Tile.SLOPE_SE) list.AddItem(AIMap.GetTileIndex(this.x, this.y + 1), Tile.SLOPE_SE); // SLOPE_SE
    }
    else if(this.towards != null){
        // If the opposite side is raised or lowered only straight is posible
        if(slope == this.towards || Tile.GetComplementSlope(slope) == this.towards)
        {
            if(this.towards == Tile.SLOPE_SW) list.AddItem(AIMap.GetTileIndex(this.x - 1, this.y), Tile.SLOPE_NE); // SLOPE_NE
            if(this.towards == Tile.SLOPE_SE) list.AddItem(AIMap.GetTileIndex(this.x, this.y - 1), Tile.SLOPE_NW); // SLOPE_NW
            if(this.towards == Tile.SLOPE_NE) list.AddItem(AIMap.GetTileIndex(this.x + 1, this.y), Tile.SLOPE_SW); // SLOPE_SW
            if(this.towards == Tile.SLOPE_NW) list.AddItem(AIMap.GetTileIndex(this.x, this.y + 1), Tile.SLOPE_SE); // SLOPE_SE
        }
        // // If one corner is lowered then we can only turn to the side not lowered
        // else if((slope & this.towards) == this.towards)
        // {
        //     // If we remove the side we're pointing to and add the opposite
        //     // corner of the one lowered we get the left or right turn
        //     local side = slope ^ this.towards;

        //     if(slope == Tile.SLOPE_NWS) side = side | Tile.SLOPE_W;
        //     else if(slope == Tile.SLOPE_WSE) side = side | Tile.SLOPE_S;
        //     else if(slope == Tile.SLOPE_SEN) side = side | Tile.SLOPE_E;
        //     else if(slope == Tile.SLOPE_ENW) side = side | Tile.SLOPE_N;

        //     if(side == Tile.SLOPE_NE) list.AddItem(AIMap.GetTileIndex(this.x - 1, this.y), Tile.SLOPE_NE); // SLOPE_NE
        //     if(side == Tile.SLOPE_NW) list.AddItem(AIMap.GetTileIndex(this.x, this.y - 1), Tile.SLOPE_NW); // SLOPE_NW
        //     if(side == Tile.SLOPE_SW) list.AddItem(AIMap.GetTileIndex(this.x + 1, this.y), Tile.SLOPE_SW); // SLOPE_SW
        //     if(side == Tile.SLOPE_SE) list.AddItem(AIMap.GetTileIndex(this.x, this.y + 1), Tile.SLOPE_SE); // SLOPE_SE
        // }
        // // If one corner is raised then we can only turn to the side not raised
        // else if(!(slope & this.towards))
        // {
        //     // Same as above but now with inverted values
        //     local side = Tile.GetComplementSlope(slope) ^ this.towards;

        //     if(slope == Tile.SLOPE_E) side = side | Tile.SLOPE_W;
        //     else if(slope == Tile.SLOPE_N) side = side | Tile.SLOPE_S;
        //     else if(slope == Tile.SLOPE_W) side = side | Tile.SLOPE_E;
        //     else if(slope == Tile.SLOPE_S) side = side | Tile.SLOPE_N;

        //     if(side == Tile.SLOPE_NE) list.AddItem(AIMap.GetTileIndex(this.x - 1, this.y), Tile.SLOPE_NE); // SLOPE_NE
        //     if(side == Tile.SLOPE_NW) list.AddItem(AIMap.GetTileIndex(this.x, this.y - 1), Tile.SLOPE_NW); // SLOPE_NW
        //     if(side == Tile.SLOPE_SW) list.AddItem(AIMap.GetTileIndex(this.x + 1, this.y), Tile.SLOPE_SW); // SLOPE_SW
        //     if(side == Tile.SLOPE_SE) list.AddItem(AIMap.GetTileIndex(this.x, this.y + 1), Tile.SLOPE_SE); // SLOPE_SE
        // }
    }

	return list;
}