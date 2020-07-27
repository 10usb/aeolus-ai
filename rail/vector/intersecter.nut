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
            return [];
        }


        if(from.origin == Tile.GetComplementSlope(terminal.origin)){
            // When the origin is equal to the compliment, the square can be on
            // either sides. Thus we need to test both sides. Prefering to
            // maintain the current diagonal en straight state
            Log.Info("Difference:" + difference);

            local absolute = difference.absolute();
            local span = min(absolute.x, absolute.y);
            local extend = max(absolute.x, absolute.y) - span;

            Log.Info("span:" + span);
            Log.Info("extend:" + extend);

            if(from.rail.direction == RailVector.DIRECTION_STRAIGHT){
                Log.Info("first straight, then diagonal");

                local copyFrom = from.Copy();
                local copyTowards = towards.Copy();
                copyFrom.rail.length = extend + 1;

                copyTowards.index = copyFrom.rail.GetTileIndex(copyFrom.index, copyFrom.origin);
                copyTowards.rail.length = span * 2;
                if((towards.rail.length & 1) == 1){
                    Log.Info("direction swapped");
                    copyTowards.rail.direction = towards.rail.direction * -1;
                    copyTowards.origin = copyFrom.origin;
                }
                copyFrom.next = copyTowards;
                
                return [copyFrom];

                Log.Info("second diagonal, then straight");
            }else{
                Log.Info("first diagonal, then straight");

                local copyFrom = from.Copy();
                local copyTowards = towards.Copy();
                copyFrom.rail.length = span * 2;
                
                copyTowards.index = copyFrom.rail.GetTileIndex(copyFrom.index, copyFrom.origin);
                copyTowards.rail.length = extend + 1;
                copyFrom.next = copyTowards;
                
                return [copyFrom];

                Log.Info("second straight, then diagonal");
            }
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

                local copy = from.Copy();

                // If the first is straigt we need to convert it to a diagonal
                if(from.rail.direction == RailVector.DIRECTION_STRAIGHT){
                    // When the length of the current diagonal is even, then we need to swap direction
                    if((towards.rail.length & 1) == 0){
                        Log.Info("direction swapped");
                        copy.rail.direction = towards.rail.direction * -1;
                    }else{
                        copy.rail.direction = towards.rail.direction;
                    }
                }

                copy.rail.length = span * 2 + 1;
                return [copy];
            }else if(extend > 0){
                if(axis == from.GetAxis()){
                    Log.Info("first diagonal, then straight");
                }else{
                    Log.Info("first straight, then diagonal");

                    local copyFrom = from.Copy();
                    local copyTowards = towards.Copy();

                    copyFrom.rail.length = extend;

                    // When the length of the current diagonal is even, then we need to swap direction
                    if((towards.rail.length & 1) == 0){
                        Log.Info("direction swapped");
                        copyTowards.rail.direction*= -1;
                    }
                    copyTowards.rail.length = span * 2 + 1;
                    copyTowards.origin = from.origin;
                    copyTowards.index = copyFrom.rail.GetTileIndex(from.index, from.origin);

                    copyFrom.next = copyTowards;

                    return [copyFrom];
                }
            }
        }
        
        return [];
    }
}
