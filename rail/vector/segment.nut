class RailVectorSegment {
    index   = null;
    origin  = null;
    rail  = null;
    bridge  = null; // When larger the 1, length of the bridge
    tunnel  = null; // When larger the 1, length of the tunnel
    next    = null;
}

function RailVectorSegment::Create(from, index, to){
    // this.signs.Build(from, "from");
    // this.signs.Build(index, "index");
    // this.signs.Build(to, "to");

    local segment = RailVectorSegment();
    segment.index = index;
    segment.origin = Tile.GetDirection(index, from);
    local towards = Tile.GetDirection(index, to);

    local distance = Tile.GetDistanceManhattanToTile(index, to);
    
    // Bridge or tunnel
    if(distance > 1){
        // It has to be straight
        if(Tile.GetComplementSlope(towards) != segment.origin) return null;
        local bridge = RailVector();
        bridge.direction = RailVector.DIRECTION_STRAIGHT;
        bridge.pitch = RailVector.PITCH_LEVEL; // for now
        bridge.length = distance;

        segment.rail = null;
        segment.bridge = bridge;
        segment.tunnel = 0;
        segment.next = null;
        return segment;
    }
    // Straight
    if(Tile.GetComplementSlope(towards) == segment.origin){
        local rail = RailVector();
        rail.direction = RailVector.DIRECTION_STRAIGHT;
        rail.pitch = RailVector.PITCH_LEVEL; // for now
        rail.length = 1;

        segment.rail = rail;
        segment.bridge = 0;
        segment.tunnel = 0;
        segment.next = null;
        return segment;
    }

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
    
    if(direction == RailVector.DIRECTION_STRAIGHT) return null;
    
    local rail = RailVector();
    rail.direction = direction;
    rail.pitch = RailVector.PITCH_LEVEL;
    rail.length = 1;

    segment.rail = rail;
    segment.bridge = 0;
    segment.tunnel = 0;
    segment.next = null;
    return segment;
}