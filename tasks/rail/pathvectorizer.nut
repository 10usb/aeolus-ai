/**
 * This task will try to vetorize the path as far as it can and then stop. The
 * can be extended and the vectorization will move on. This allowes an other
 * task to already use the vectors that have been mapped while the path is not
 * yet complete.
 */
class RailPathVectorizer extends Task {
    path = null;
    index = null;
    root = null;
    current = null;
    signs = null;

	constructor(){
        this.path = [];
        this.index = 0;
        this.root = null;
        this.current = null;
        this.signs = Signs();
	}

    function GetName(){
        return "RailPathVectorizer";
    }

    function GetRoot(){
        return this.root;
    }

    function Append(path){
        this.path.extend(path);
    }

    function Run(){
        if(this.root == null){
            this.root = RailVectorSegment.Create(this.path[0], this.path[1], this.path[2]);
            this.current = root;
            this.index = 3;
            return true;
        }

        local limit = 100000;
        while(limit--> 0 && this.index < this.path.len()){
            signs.Build(this.path[this.index], "#");

            if(this.CanExtend()){
                this.current.rail.length++;

                this.signs.Build(this.path[this.index - 1], "[" + this.current.rail.length + "]");
            }else{
                local next = RailVectorSegment.Create(this.path[this.index - 2], this.path[this.index - 1], this.path[this.index]);
                this.current.next = next;
                this.current = next;
                
                // Bridges has a ramp we need to skip
                if(this.current.bridge) this.index++;

                if(this.current.rail){
                    signs.Build(this.current.index, "P:" + this.current.rail.pitch);
                }
            }
    
            this.index++;
        }

        if(this.index < this.path.len()) return true;

        this.signs.Clean();
        return false;
    }

    function CanExtend(){
        // Only rail can be extended
        if(this.current.rail == null) return false;

        // The terminal + 1 should be equal to the current to inspect index
        local match = this.current.rail.GetTileIndex(this.current.index, this.current.origin, this.current.rail.length + 1);
        if(match != this.path[this.index]) return false;

        // For straight track that can go up and down check if the height matches
        if(this.current.rail.direction == RailVector.DIRECTION_STRAIGHT){
            switch(this.current.rail.pitch){
                case RailVector.PITCH_LEVEL:
                    // When level, the tiles should be flat
                    if(Tile.GetSlope(this.path[this.index - 1]) != Tile.SLOPE_FLAT) return false;
                    // When level, tiles should be at same height
                    if(Tile.GetMaxHeight(this.current.index) != Tile.GetMaxHeight(this.path[this.index - 1])) return false;
                break;
                case RailVector.PITCH_UP:
                    // When it go's up the max height should be climbing with the length
                    if((Tile.GetMaxHeight(this.current.index) + this.current.rail.length) != Tile.GetMaxHeight(this.path[this.index - 1])) return false;
                break;
                case RailVector.PITCH_DOWN:
                    // When it's down the height should drop with the length
                    if((Tile.GetMinHeight(this.current.index) - this.current.rail.length) != Tile.GetMinHeight(this.path[this.index - 1])) return false;
                break;
            }
        }

        return true;
    }
}