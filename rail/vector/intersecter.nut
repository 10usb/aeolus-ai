class RailVectorIntersecter {
    // To intersect to segments we use the most outwards entries of both and
    // get the difference of x and y. Of this rectangle we take the square by
    // using the shortes of x or y. This wil be the diagonal part, the
    // remaining difference of x and y will be the straight part
    function Intersect(from, towards){
        local difference = from.GetVector().difference(terminal.GetVector());

        if(difference.x == 0 || difference.y == 0){
            Log.Error("Idk");
            return [];
        }

        if(from.origin == Tile.GetComplementSlope(towards.origin)){
            // When the origin is equal to the compliment, the square can be on
            // either sides. Thus we need to test both sides. Prefering to
            // maintain the current diagonal en straight state
            Log.Info("Difference:" + difference);

            local absolute = difference.absolute();
            local span = min(absolute.x, absolute.y);
            local extend = max(absolute.x, absolute.y) - span;

            Log.Info("span:" + span);
            Log.Info("extend:" + extend);

            return this.IntersectComplement(from, towards, difference);
        }else if(from.origin != terminal.origin){
            return this.IntersectTurn(from, towards, difference);
        }
        
        return [];
    }

    function IntersectComplement(from, towards, difference){
        return [];
    }

    function IntersectTurn(from, towards, difference){
        return [];
    }
}
