class RailVectorSegment {
    index   = null;
    origin  = null;
    rail  = null;
    bridge  = null; // When larger the 1, length of the bridge
    tunnel  = null; // When larger the 1, length of the tunnel
    next    = null;
}

// Parses an array of tiles into a linked list segments
function RailVectorSegment::Parse(path){
    if(path.len() < 3) return false;

    local root = RailVectorSegment.Create(path[0], path[1], path[2]);
    local current = root;
    local index = 3;

    //this.signs = Signs();
    while(current != null && index < path.len()){
        // this.signs.Build(path[index], "#");

        if(current.rail != null){
            local match = current.rail.GetTileIndex(current.index, current.origin, current.rail.length + 1);
            if(match == path[index]){
                // this.signs.Build(match, "match");

                current.rail.length++;
            }else{
                local next = RailVectorSegment.Create(path[index - 2], path[index - 1], path[index]);
                current.next = next;
                current = next;
            }
        }else{
            local next = RailVectorSegment.Create(path[index - 2], path[index - 1], path[index]);
            current.next = next;
            current = next;
        }
        if(current.bridge){
            index++;
        }

        index++;
        
        // Controller.Sleep(10);
        // this.signs.Clean();
    }

    return root;
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