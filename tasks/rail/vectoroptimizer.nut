/**
 * This task will try to reduce the amount of vectors by aliging them on to
 * each other. By doing this, it smooths out the path to build. Every segment
 * that is very short and will reduce the speed of the train alot, will be
 * attempted to made longer. Given a budget it can even consider terrain
 * alteration to that amount.
 */
 class RailVectorOptimizer extends Task {
    root = null;
    current = null;
    trail = null;

	constructor(root, trail){
        this.root = root;
        this.trail = trail;
    }

    function GetName(){
        return "RailVectorOptimizer";
    }
    
    function Run(){
        if(this.current == null){
            this.current = this.root;
        }

        local changed = false;
        while(this.current){
            if(this.current.rail && this.current.rail.pitch == RailVector.PITCH_LEVEL){
                if(this.FlatIntersect(this.current))
                    changed = true;
            }
            
            this.current = this.current.next;
        }

        return changed;
    }

    /**
     * Test if the 3rd segment from this one can be intersected, and be build.
     * This is done without one of the next is on a diffrent height.
     */
    function FlatIntersect(segment){
        if(segment.rail.direction == RailVector.DIRECTION_STRAIGHT){
            return this.FlatIntersectStraight(segment);
        }else{
            return this.FlatIntersectDiagonal(segment);
        }
    }
    
    function FlatIntersectStraight(segment){
        local pointer = segment.next;

        // The next turn
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
          ) {
              Log.Info("1");
              return false;
          }

        // The straight
        pointer = pointer.next;
        if(pointer == null
            || pointer.rail == null
            || pointer.rail.pitch != RailVector.PITCH_LEVEL
            || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
           ) {
            Log.Info("2");
            return false;
        }

        // And the turn we might be able to connect to
        pointer = pointer.next;
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
          ) {
            Log.Info("3");
            return false;
        }

        if(pointer.next == null && !trail) return false;
        
        
        foreach(new in RailVectorIntersecter.Intersect(segment, pointer.GetExit())){
            if(this.CanBuild(new)){
                Log.Info("I1");
                segment.ReplaceWith(new);

                // The exit of "new" should be equal to the exit of pointer, thus
                // we can assume it fits to the next segment of pointer
                if(segment.next != null){
                    segment.next.next = pointer.next;
                }else{
                    segment.next = pointer.next;
                }
                return true;
            }
        }
        return false;
    }
    
    function FlatIntersectDiagonal(segment){
        local pointer = segment.next;

        // The next turn
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
          ) {
            Log.Info("4");
            return false;
        }

        // The straight
        pointer = pointer.next;
        if(pointer == null
            || pointer.rail == null
            || pointer.rail.pitch != RailVector.PITCH_LEVEL
            || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
           ) {
            Log.Info("5");
            return false;
        }

        // And the turn we might be able to connect to
        pointer = pointer.next;
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
          ) {
            Log.Info("6");
            return false;
        }

        if(pointer.next == null && !trail) return;

        
        foreach(new in RailVectorIntersecter.Intersect(segment, pointer.GetExit())){
            if(this.CanBuild(new)){
                Log.Info("I2");
                segment.ReplaceWith(new);

                // The exit of "new" should be equal to the exit of pointer, thus
                // we can assume it fits to the next segment of pointer
                if(segment.next != null){
                    segment.next.next = pointer.next;
                }else{
                    segment.next = pointer.next;
                }
                return true;
            }
        }
        return false;
    }
    
    function CanBuild(segment){
        local tiles = List();
        
        for(local offset = 0; offset < segment.rail.length; offset++){
            local index = segment.rail.GetTileIndex(segment.index, segment.origin, offset);
            tiles.AddItem(index, 0);
        }

        // Get the count to compare against, as one invalid removed makes the equation false
        local count = tiles.Count();

        // Make sure the tiles are buildable
        tiles.Valuate(Tile.IsBuildable);
        tiles.RemoveValue(0);
        if(tiles.Count() != count) return false;

        // Although costal tiles aren't flat this is faster
        tiles.Valuate(Tile.IsCoastTile);
        tiles.RemoveValue(1);
        if(tiles.Count() != count) return false;

        // Check is the rail parts of a tile are flat
        if(!this.IsFlat(segment)) return false;

        if(segment.next == null) return true;
        return this.CanBuild(segment.next);
    }
    
    function IsFlat(segment){
        // Checking the flatness of straight tile is easy, we just get the slope of it, and it needs to be flat
        if(segment.rail.direction == RailVector.DIRECTION_STRAIGHT){
            for(local offset = 0; offset < segment.rail.length; offset++){
                local index = segment.rail.GetTileIndex(segment.index, segment.origin, offset);
                if(Tile.GetSlope(index) != Tile.SLOPE_FLAT) return false;
            }
            return true;
        }

        local height = 0;
        foreach(corner, value in Tile.GetCorners(segment.origin)){
            height+= Tile.GetCornerHeight(segment.index,  corner);
        }

        // 2 corners at different level should be uneven
        if(height & 1) return false;

        // Now normalize to 1
        height = height / 2;
        
        // TODO check only the corners that need to be flat
        for(local offset = 1; offset < segment.rail.length; offset++){
            local index = segment.rail.GetTileIndex(segment.index, segment.origin, offset);

            if(Tile.GetSlope(index) == Tile.SLOPE_FLAT) continue;

            local origin = segment.rail.GetTileOrigin(segment.origin, offset);
            
            foreach(corner, value in Tile.GetCorners(origin)){
                if(Tile.GetCornerHeight(index,  corner) != height) return false;
            }
        }

        return true;
    }
}