class RailVectorIntersecter {
    // To intersect to segments we use the most outwards entries of both and
    // get the difference of x and y. Of this rectangle we take the square by
    // using the shortes of x or y. This wil be the diagonal part, the
    // remaining difference of x and y will be the straight part
    function Intersect(from, towards){
        local difference = from.GetVector().difference(towards.GetVector());

        if(difference.x == 0 || difference.y == 0){
            Log.Error("Idk");
            return [];
        }

        
        Log.Info("Difference:" + difference);


        if(from.origin == Tile.GetComplementSlope(towards.origin)){
            // When the origin is equal to the complement, the square can be on
            // either sides. Thus we need to test both sides. Prefering to
            // maintain the current diagonal and straight state

            local absolute = difference.absolute();

            local axis = Tile.GetAxis(from.origin);
            local span, extend;
            if(axis == Tile.AXIS_X){
                span = absolute.y;
                extend = absolute.x - span + 1;
            }else{
                span = absolute.x;
                extend = absolute.y - span + 1;
            }

            if(extend < 0) return [];

            local direction = RailVectorIntersecter.GetDirection(from.origin, difference);
            Log.Info("span:" + span);
            Log.Info("extend:" + extend);
            Log.Info("direction:" + RailVector.GetDirectionName(direction));

            local diagonal = RailVectorSegment();
            diagonal.rail = RailVector();
            diagonal.bridge = null;
            diagonal.tunnel = null;
            diagonal.next = null;
            diagonal.rail.direction = direction;
            diagonal.rail.pitch = RailVector.PITCH_LEVEL;
            diagonal.rail.length = span * 2;

            if(extend == 0){
                diagonal.index = from.index;
                diagonal.origin = from.origin;
                return [diagonal];
            }
            
            local straight = RailVectorSegment();
            straight.rail = RailVector();
            straight.bridge = null;
            straight.tunnel = null;
            straight.next = null;
            straight.rail.direction = RailVector.DIRECTION_STRAIGHT;
            straight.rail.pitch = RailVector.PITCH_LEVEL;
            straight.rail.length = extend;

            local segments = [];

            if(from.rail.direction == RailVector.DIRECTION_STRAIGHT){
                local copy = straight.Copy();
                copy.next = diagonal.Copy();

                copy.index = from.index;
                copy.origin = from.origin;

                copy.next.index = copy.rail.GetTileIndex(copy.index, copy.origin);
                copy.next.origin = from.origin;
                segments.push(copy);

                //
                diagonal.next = straight;

                diagonal.index = from.index;
                diagonal.origin = from.origin;

                straight.index = diagonal.rail.GetTileIndex(diagonal.index, diagonal.origin);
                straight.origin = from.origin;

                segments.push(diagonal);
            }else{
                local copy = diagonal.Copy();
                copy.next = straight.Copy();

                copy.index = from.index;
                copy.origin = from.origin;

                copy.next.index = copy.rail.GetTileIndex(copy.index, copy.origin);
                copy.next.origin = from.origin;
                segments.push(copy);

                //
                straight.next = diagonal;

                straight.index = from.index;
                straight.origin = from.origin;

                diagonal.index = straight.rail.GetTileIndex(straight.index, straight.origin);
                diagonal.origin = from.origin;

                segments.push(straight);
            }

            return segments;
        }else if(from.origin != towards.origin){
            return [];
        }
        
        return [];
    }

    function GetDirection(origin, difference){
        switch(origin){
            case Tile.SLOPE_NW:
                if(difference.x == 0) throw("Invalid difference");
                return difference.x < 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
            case Tile.SLOPE_SE:
                if(difference.x == 0) throw("Invalid difference");
                return difference.x > 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
            case Tile.SLOPE_NE:
                if(difference.x == 0) throw("Invalid difference");
                return difference.x > 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
            case Tile.SLOPE_SW:
                if(difference.x == 0) throw("Invalid difference");
                return difference.x < 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
        }
        throw("Unknown Slope");
    }
}
