class RailVectorSegment extends MapEntry {
    rail    = null;
    bridge  = null; // When larger the 1, length of the bridge
    tunnel  = null; // When larger the 1, length of the tunnel
    next    = null;

    constructor(){
    }

    function GetExit(){
        if(this.rail != null){
            return MapEntry.CreateFromTile(this.rail.GetTileIndex(this.index, this.origin), this.rail.GetTileIndex(this.index, this.origin, this.rail.length - 1));
        }

        return null;
    }

    /**
     * Makes a copy of only this segment and this segment also doesn't point to
     * a next one even if the original did.
     */
    function Copy(){
        local copy = RailVectorSegment();
        copy.index = this.index;
        copy.origin = this.origin;
        if(this.rail) copy.rail = clone this.rail;
        if(this.bridge) copy.bridge = clone this.bridge;
        if(this.tunnel) copy.tunnel = clone this.tunnel;
        copy.next = null;
        return copy;
    }

    /**
     * Replaces the inner values with that of the other segment
     */
    function ReplaceWith(other){
        if(this.index != other.index) throw "Index not equal";
        if(this.origin != other.origin) throw "Origin not equal";
        this.rail = other.rail;
        this.bridge = other.bridge;
        this.tunnel = other.tunnel;
        this.next = other.next;
    }
}

function RailVectorSegment::Create(from, index, to){
    local segment = RailVectorSegment();
    segment.index = index;
    segment.origin = Tile.GetDirection(index, from);
    local towards = Tile.GetDirection(index, to);

    local distance = Tile.GetDistanceManhattanToTile(index, to);
    
    // Bridge or tunnel
    if(distance > 1) return RailVectorSegment.CreateJump(segment, towards, distance);

    // Straight
    if(Tile.GetComplementSlope(towards) == segment.origin) return RailVectorSegment.CreateStraight(segment, towards);

    // Taking a turn (diagonal)
    return RailVectorSegment.CreateTurn(segment, towards);
}

function RailVectorSegment::CreateJump(segment, towards, distance){
    // It has to be straight
    if(Tile.GetComplementSlope(towards) != segment.origin) return null;

    local bridge = RailVector();
    bridge.direction = RailVector.DIRECTION_STRAIGHT;
    bridge.pitch = RailVector.PITCH_LEVEL;
    bridge.length = distance;

    segment.rail = null;
    segment.bridge = bridge;
    segment.tunnel = 0;
    segment.next = null;
    return segment;
}

function RailVectorSegment::CreateStraight(segment, towards){
    local slope = Tile.GetSlope(segment.index);

    local rail = RailVector();
    rail.direction = RailVector.DIRECTION_STRAIGHT;
    if(slope == Tile.SLOPE_FLAT){
        rail.pitch = RailVector.PITCH_LEVEL;
    }else if(slope == towards){
        rail.pitch = RailVector.PITCH_UP;
    }else if(slope == segment.origin){
        rail.pitch = RailVector.PITCH_DOWN;
    }else throw "Building on slopes not supported";

    rail.length = 1;

    segment.rail = rail;
    segment.bridge = null;
    segment.tunnel = null;
    segment.next = null;
    return segment;
}

function RailVectorSegment::CreateTurn(segment, towards){
    // Are we going left or right
    local direction = RailVector.DIRECTION_STRAIGHT;
    switch(segment.origin){
        case Tile.SLOPE_NE:
            if(towards == Tile.SLOPE_NW){
                direction = RailVector.DIRECTION_RIGHT;
            }else if(towards == Tile.SLOPE_SE){
                direction = RailVector.DIRECTION_LEFT;
            }
        break;
        case Tile.SLOPE_NW:
            if(towards == Tile.SLOPE_SW){
                direction = RailVector.DIRECTION_RIGHT;
            }else if(towards == Tile.SLOPE_NE){
                direction = RailVector.DIRECTION_LEFT;
            }
        break;
        case Tile.SLOPE_SW:
            if(towards == Tile.SLOPE_SE){
                direction = RailVector.DIRECTION_RIGHT;
            }else if(towards == Tile.SLOPE_NW){
                direction = RailVector.DIRECTION_LEFT;
            }
        break;
        case Tile.SLOPE_SE:
            if(towards == Tile.SLOPE_NE){
                direction = RailVector.DIRECTION_RIGHT;
            }else if(towards == Tile.SLOPE_SW){
                direction = RailVector.DIRECTION_LEFT;
            }
        break;
    }
    
    // If this is true, then some idjit make a programming mistake 
    if(direction == RailVector.DIRECTION_STRAIGHT) throw "Invalid segments";
    
    local rail = RailVector();
    rail.direction = direction;
    rail.pitch = RailVector.PITCH_LEVEL;
    rail.length = 1;

    segment.rail = rail;
    segment.bridge = null;
    segment.tunnel = null;
    segment.next = null;
    return segment;
}