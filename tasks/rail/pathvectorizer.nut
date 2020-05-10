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

	constructor(){
        path = [];
        index = 0;
        root = null;
        current = null;
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

        local signs = Signs();

        local limit = 100000;
        while(limit--> 0 && this.index < this.path.len()){
            //signs.Build(this.path[this.index], "#");
    
            if(this.current.rail != null){
                local match = this.current.rail.GetTileIndex(this.current.index, this.current.origin, this.current.rail.length + 1);

                if(match == this.path[this.index]){
                    //signs.Build(match, "match");
    
                    this.current.rail.length++;
                }else{
                    local next = RailVectorSegment.Create(this.path[this.index - 2], this.path[this.index - 1], this.path[this.index]);
                    this.current.next = next;
                    this.current = next;
                }
            }else{
                local next = RailVectorSegment.Create(this.path[this.index - 2], this.path[this.index - 1], this.path[this.index]);
                this.current.next = next;
                this.current = next;
            }
            if(this.current.bridge){
                this.index++;
            }
    
            this.index++;
            
            signs.Clean();
        }

        return this.index < this.path.len();
    }
}