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

    /**
     * Get the possible candidates in order of left, right, straight
     */
    function GetCandidates(){
        local list = [];

        switch(this.towards){
            case Tile.SLOPE_NW:
                list.push({ index=AIMap.GetTileIndex(this.x - 1, this.y), direction=Tile.SLOPE_NE });
                list.push({ index=AIMap.GetTileIndex(this.x + 1, this.y), direction=Tile.SLOPE_SW });                
                list.push({ index=AIMap.GetTileIndex(this.x, this.y + 1), direction=Tile.SLOPE_SE });
            break;
            case Tile.SLOPE_NE:
                list.push({ index=AIMap.GetTileIndex(this.x, this.y + 1), direction=Tile.SLOPE_SE });
                list.push({ index=AIMap.GetTileIndex(this.x, this.y - 1), direction=Tile.SLOPE_NW });
                list.push({ index=AIMap.GetTileIndex(this.x + 1, this.y), direction=Tile.SLOPE_SW });
            break;
            case Tile.SLOPE_SE:
                list.push({ index=AIMap.GetTileIndex(this.x + 1, this.y), direction=Tile.SLOPE_SW });
                list.push({ index=AIMap.GetTileIndex(this.x - 1, this.y), direction=Tile.SLOPE_NE });
                list.push({ index=AIMap.GetTileIndex(this.x, this.y - 1), direction=Tile.SLOPE_NW });
            break;
            case Tile.SLOPE_SW:
                list.push({ index=AIMap.GetTileIndex(this.x - 1, this.y), direction=Tile.SLOPE_NE });
                list.push({ index=AIMap.GetTileIndex(this.x, this.y - 1), direction=Tile.SLOPE_NW });
                list.push({ index=AIMap.GetTileIndex(this.x, this.y + 1), direction=Tile.SLOPE_SE });
            break;
        }

        return list;
    }
}