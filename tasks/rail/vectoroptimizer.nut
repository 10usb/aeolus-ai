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

	constructor(root){
        this.root = root;
    }

    function GetName(){
        return "RailVectorOptimizer";
    }
    
    function Run(){
        if(this.current == null){
            this.current = this.root;
        }

        while(this.current){
            if(this.current.rail){
                this.FlatIntersect(this.current);
            }
            
            this.current = this.current.next;
        }

        return false;
    }

    /**
     * Test if the 3rd segment from this one can be intersected, and be build.
     * This is done without one of the next is on a diffrent height.
     */
    function FlatIntersect(segment){
        if(segment.rail.direction == RailVector.DIRECTION_STRAIGHT){
            this.FlatIntersectStraight(segment);
        }else{
            this.FlatIntersectDiagonal(segment);
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
              return;
          }

        // The straight
        pointer = pointer.next;
        if(pointer == null
            || pointer.rail == null
            || pointer.rail.pitch != RailVector.PITCH_LEVEL
            || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
           ) {
            Log.Info("2");
            return;
        }

        // And the turn we might be able to connect to
        pointer = pointer.next;
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
          ) {
            Log.Info("3");
            return;
        }
        
        Log.Info("I1");
        foreach(new in RailVectorIntersecter.Intersect(segment, pointer)){
            if(this.CanBuild(new)){
                segment.ReplaceWith(new);

                // The exit of "new" should be equal to the exit of pointer, thus
                // we can assume it fits to the next segment of pointer
                if(segment.next != null){
                    segment.next.next = pointer.next;
                }else{
                    segment.next = pointer.next;
                }
            }
        }
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
            return;
        }

        // The straight
        pointer = pointer.next;
        if(pointer == null
            || pointer.rail == null
            || pointer.rail.pitch != RailVector.PITCH_LEVEL
            || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
           ) {
            Log.Info("5");
            return;
        }

        // And the turn we might be able to connect to
        pointer = pointer.next;
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
          ) {
            Log.Info("6");
            return;
        }

        Log.Info("I2");
        foreach(new in RailVectorIntersecter.Intersect(segment, pointer)){
            if(this.CanBuild(new)){
                segment.ReplaceWith(new);

                // The exit of "new" should be equal to the exit of pointer, thus
                // we can assume it fits to the next segment of pointer
                if(segment.next != null){
                    segment.next.next = pointer.next;
                }else{
                    segment.next = pointer.next;
                }
            }
        }
    }
    
    function CanBuild(segment){
        return true;
    }
}