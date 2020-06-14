class RailVectorIntersecter {
    // To intersect to segments we use the most outwards entries of both and
    // get the difference of x and y. Of this rectangle we take the square by
    // using the shortes of x or y. This wil be the diagonal part, the
    // remaining difference of x and y will be the straight part
    function Intersect(from, towards){
        local terminal = towards.GetExit();

        local difference = from.GetVector().difference(terminal.GetVector());

        if(difference.x == 0 || difference.y == 0){
            Log.Info("Idk");
            return;
        }

        Log.Info("Difference:" + difference);

        if(from.origin == Tile.GetComplementSlope(terminal.origin)){
            // When the origin is equal to the compliment the square can be on
            // either sides, thus we need to test both. prefering to maintain the
            // current diagonal en straight state
        }else if(from.origin != terminal.origin){
            local absolute = difference.absolute();
            local span = min(absolute.x, absolute.y);
            local extend = max(absolute.x, absolute.y) - span;
            local axis = span == absolute.x ? Tile.AXIS_X : Tile.AXIS_Y;

            // span*2+1;

            Log.Info("span:" + span);
            Log.Info("extend:" + extend);
            Log.Info("axis:" + Tile.GetAxisName(axis));
            Log.Info("F-axis:" + Tile.GetAxisName(from.GetAxis()));

            if(extend == 0){
                Log.Info("only diagonal remain:");

                // If the first is straigt we need to convert it to a diagonal
                if(from.rail.direction == RailVector.DIRECTION_STRAIGHT){
                    // When the length of the current diagonal is even, then we need to swap direction
                    if((towards.rail.length & 1) == 0){
                        Log.Info("direction swapped");
                        from.rail.direction= towards.rail.direction * -1;
                    }else{
                        from.rail.direction= towards.rail.direction;
                    }
                }

                from.rail.length = span * 2 + 1;
                // second can be skiped so we point to the next of that one
                from.next = towards.next;
                // TODO: If the now next is a diagonal and in the same direction it can be merged
            }else if(extend > 0){
                if(axis == from.GetAxis()){
                    Log.Info("first diagonal, then straight");
                }else{
                    Log.Info("first straight, then diagonal");
                    from.rail.length = extend;

                    // When the length of the current diagonal is even, then we need to swap direction
                    if((towards.rail.length & 1) == 0){
                        Log.Info("direction swapped");
                        towards.rail.direction*= -1;
                    }
                    towards.rail.length = span * 2 + 1;
                    towards.origin = from.origin;
                    towards.index = from.rail.GetTileIndex(from.index, from.origin);

                    from.next = towards;
                }
            }
        }
    }
}
