class RailVector {
    static DIRECTION_LEFT = -1;
    static DIRECTION_STRAIGHT = 0;
    static DIRECTION_RIGHT = 1;

    static PITCH_UP = 1;
    static PITCH_LEVEL = 0;
    static PITCH_DOWN = -1;
    
	direction   = 0; // left, straight, right
    pitch	    = 0; // up, level, down
    length      = 0; // number of rail parts


    // Returns the origin the tile needs to have to connect to the end of this vector
    function GetTileOrigin(origin){
        switch(this.direction){
            case RailVector.DIRECTION_LEFT:
                switch(origin){
                    case Tile.SLOPE_NE: return this.length & 1 ? Tile.SLOPE_NW : Tile.SLOPE_NE;
                    case Tile.SLOPE_NW: return this.length & 1 ? Tile.SLOPE_SW : Tile.SLOPE_NW;
                    case Tile.SLOPE_SW: return this.length & 1 ? Tile.SLOPE_SE : Tile.SLOPE_SW;
                    case Tile.SLOPE_SE: return this.length & 1 ? Tile.SLOPE_NE : Tile.SLOPE_SE;
                }
            break;
            case RailVector.DIRECTION_RIGHT:
                switch(origin){
                    case Tile.SLOPE_NE: return this.length & 1 ? Tile.SLOPE_SE : Tile.SLOPE_NE;
                    case Tile.SLOPE_NW: return this.length & 1 ? Tile.SLOPE_NE : Tile.SLOPE_NW;
                    case Tile.SLOPE_SW: return this.length & 1 ? Tile.SLOPE_NW : Tile.SLOPE_SW;
                    case Tile.SLOPE_SE: return this.length & 1 ? Tile.SLOPE_SW : Tile.SLOPE_SE;
                }
            break;
            case RailVector.DIRECTION_STRAIGHT: return origin;
            default: return Tile.SLOPE_INVALID;
        }
    }

    // Returns the tile index the vector points to
    // @param index The tile index where the vector starts
    // @param origin The side of the tile the vector is originating from
    // @return The tile index next inline
    function GetTileIndex(index, origin, length = -1){
        if(length == 0) return index;

        local x = AIMap.GetTileX(index);
        local y = AIMap.GetTileY(index);

        if(length < 0) length = this.length;

        switch(this.direction){
            case RailVector.DIRECTION_LEFT:
                local v1 = (length + 1) / 2;
                local v2 = (length) / 2;

                switch(origin){
                    case Tile.SLOPE_NE: return AIMap.GetTileIndex(x + v2, y + v1);
                    case Tile.SLOPE_NW: return AIMap.GetTileIndex(x - v1, y + v2);
                    case Tile.SLOPE_SW: return AIMap.GetTileIndex(x - v2, y - v1);
                    case Tile.SLOPE_SE: return AIMap.GetTileIndex(x + v1, y - v2);
                }
            break;
            case RailVector.DIRECTION_RIGHT:
                local v1 = (length + 1) / 2;
                local v2 = (length) / 2;

                switch(origin){
                    case Tile.SLOPE_NE: return AIMap.GetTileIndex(x + v2, y - v1);
                    case Tile.SLOPE_NW: return AIMap.GetTileIndex(x + v1, y + v2);
                    case Tile.SLOPE_SW: return AIMap.GetTileIndex(x - v2, y + v1);
                    case Tile.SLOPE_SE: return AIMap.GetTileIndex(x - v1, y - v2);
                }
            break;
            case RailVector.DIRECTION_STRAIGHT: 
                switch(origin){
                    case Tile.SLOPE_NE: return AIMap.GetTileIndex(x + length, y);
                    case Tile.SLOPE_NW: return AIMap.GetTileIndex(x, y + length);
                    case Tile.SLOPE_SW: return AIMap.GetTileIndex(x - length, y);
                    case Tile.SLOPE_SE: return AIMap.GetTileIndex(x, y - length);
                }
            break;
            default: return Tile.SLOPE_INVALID;
        }
    }
}

function RailVector::GetDirectionName(direction){
    switch(direction){
        case RailVector.DIRECTION_LEFT: return "Left";
        case RailVector.DIRECTION_STRAIGHT: return "Straight";
        case RailVector.DIRECTION_RIGHT: return "Right";
    }
    throw("Unknown direction");
}