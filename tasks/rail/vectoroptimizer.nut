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
        while(current){
            if(current.rail){
                this.FlatIntersect(current);
            }

            current = current.next;
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
          ) return;

        // The straight
        pointer = segment.next;
        if(pointer == null
            || pointer.rail == null
            || pointer.rail.pitch != RailVector.PITCH_LEVEL
            || pointer.rail.direction != RailVector.DIRECTION_STRAIGHT
           ) return;

        // And the turn we might be able to connect to
        pointer = segment.next;
        if(pointer == null
           || pointer.rail == null
           || pointer.rail.pitch != RailVector.PITCH_LEVEL
           || pointer.rail.direction == RailVector.DIRECTION_STRAIGHT
          ) return;
        
        local reversed = pointer.Reverse();
        
        // Getting the tile 2 lengths will result in a +/- 1 in X aswell Y
        reversed.rail.GetTileIndex(reversed.index, reversed.origin, 2);

        // TODO check if we are moving towards or away from segment
        
        // TODO if the straight vector is moving along the x-axis, then get the
        // terminal tile of the diagonal vector by using y-axis
        // (difference / 2 + 1) or + 2 if the origin of the diagonal is not the
        // compliment of the straigt vector compliment. Then the difference in
        // y-axis of the diagonal may not be larger then the difference between
        // the indexes of the diagonal and straight vectors
    }
    
    function FlatIntersectDiagonal(segment){

    }
}