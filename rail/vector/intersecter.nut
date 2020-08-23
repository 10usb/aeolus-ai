class RailVectorIntersecter {
    // To intersect to segments we use the most outwards entries of both and
    // get the difference of x and y. Of this rectangle we take the square by
    // using the shortes of x or y. This wil be the diagonal part, the
    // remaining difference of x and y will be the straight part
    function Intersect(from, towards){
        local difference = from.GetVector().difference(towards.GetVector());

        if(from.origin == Tile.GetComplementSlope(towards.origin)){
            return RailVectorIntersecter.IntersectComplement(from, towards, difference);
        }else if(from.origin != towards.origin){
            return RailVectorIntersecter.IntersectTurn(from, towards, difference);
        }
        
        return [];
    }

    // When the origin is equal to the complement, the square can be on
    // either sides. Thus we need to test both sides. Prefering to
    // maintain the current diagonal and straight state
    function IntersectComplement(from, towards, difference){
        if(difference.x == 0 || difference.y == 0){
            Log.Error("Make one big straight?");
            return [];
        }

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

        Log.Info(" ----- complement ------");
        Log.Info("difference:" + difference);
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
    }

    // When we make a turn of sides, then the diagonal part is the shortes difference
    // If it's not a square then the straight part could be as first or as last
    function IntersectTurn(from, towards, difference){
        local absolute = difference.absolute();

        local span = Math.min(absolute.x, absolute.y);
        local extend = Math.max(absolute.x, absolute.y) - span;
        local direction = RailVectorIntersecter.GetDirection(from.origin, difference);

        Log.Info(" ----- turn ------");
        Log.Info("difference:" + difference);
        Log.Info("span:" + span);
        Log.Info("extend:" + extend);
        Log.Info("origin:" + Tile.GetSlopeName(from.origin));
        Log.Info("direction:" + RailVector.GetDirectionName(direction));


        local diagonal = RailVectorSegment();
        diagonal.rail = RailVector();
        diagonal.bridge = null;
        diagonal.tunnel = null;
        diagonal.next = null;
        diagonal.rail.direction = direction;
        diagonal.rail.pitch = RailVector.PITCH_LEVEL;
        diagonal.rail.length = span * 2 + 1;

        if(diagonal.rail.GetTileOrigin(from.origin) != Tile.GetComplementSlope(towards.origin)){
            Log.Error("Can't build");
            return [];
        }

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
        
        local axis = Tile.GetAxis(from.origin);
        local reversed;
        if(axis == Tile.AXIS_X){
            reversed = absolute.x != span;
        }else{
            reversed = absolute.y != span;
        }
        Log.Info("reversed:" + reversed);

        if(reversed){
            straight.index = from.index;
            straight.origin = from.origin;
            straight.next = diagonal;

            diagonal.index = straight.rail.GetTileIndex(straight.index, straight.origin);
            diagonal.origin = straight.origin;

            Log.Info("origin:" + Tile.GetSlopeName(diagonal.origin));
            return [straight];
        }else{
            diagonal.index = from.index;
            diagonal.origin = from.origin;
            diagonal.next = straight;

            straight.index = diagonal.rail.GetTileIndex(diagonal.index, diagonal.origin);
            straight.origin = diagonal.rail.GetTileOrigin(diagonal.origin);

            Log.Info("index:" + Tile.GetX(straight.index) + "x" + Tile.GetY(straight.index));
            Log.Info("origin:" + Tile.GetSlopeName(straight.origin));
            return [diagonal];
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
                if(difference.y == 0) throw("Invalid difference");
                return difference.y > 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
            case Tile.SLOPE_SW:
                if(difference.y == 0) throw("Invalid difference");
                return difference.y < 0 ? RailVector.DIRECTION_LEFT : RailVector.DIRECTION_RIGHT;
        }
        throw("Unknown Slope");
    }
}
