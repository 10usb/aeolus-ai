/**
 * This rail processor task will try to optimize the path received before
 * constructing it. First it will transform the array of tiles into vectors.
 * These vectors can then be aligned opon each other and tested. Thus removeing
 * the vectors inbetween, giving a more smooth rail.
 */
class RailPathOptimizer extends Task {
    railType = null;
    vectorizer = null;
    state = null;
    current = null;
    
	constructor(railType){
        this.railType = railType;
        this.vectorizer = RailPathVectorizer();
        this.state = 0;
        this.current = null;
	}

    function GetName(){
        return "RailPathOptimizer";
    }

    function Append(path){
        this.vectorizer.Append(path);

        if(this.state == 0){
            this.state = 1;
        }
    }

    function Finalize(){
        this.state = 3;
    }

    function Run(){
        if(this.state == 1){
            this.PushTask(this.vectorizer);
            this.state = 2;
            return true;
        }

        if(this.state == 2){
            if(this.current == null){
                this.current = this.vectorizer.GetRoot();
            }

            Rail.SetCurrentRailType(this.railType);

            while(this.current.next != null){
                if(this.current.rail != null){
                    //signs.Build(current.index, "rail");
                    RailVectorBuilder.BuildRail(this.current.rail, this.current.index, this.current.origin);
                }else if(this.current.bridge != null){
                    //signs.Build(current.index, "bridge");
                    RailVectorBuilder.BuildBridge(this.current.bridge, this.current.index, this.current.origin);
                }
                this.current = this.current.next;
            }
            
            this.state = 0;
            return false;
        }

        if(this.state == 3){
            this.PushTask(this.vectorizer);
            this.state = 4;
            return true;
        }

        if(this.state == 4){
            if(this.current == null){
                this.current = this.vectorizer.GetRoot();
            }

            Rail.SetCurrentRailType(this.railType);

            while(this.current != null){
                if(this.current.rail != null){
                    //signs.Build(current.index, "rail");
                    RailVectorBuilder.BuildRail(this.current.rail, this.current.index, this.current.origin);
                }else if(this.current.bridge != null){
                    //signs.Build(current.index, "bridge");
                    RailVectorBuilder.BuildBridge(this.current.bridge, this.current.index, this.current.origin);
                }
                this.current = this.current.next;
            }
            return false;
        }

        return false;
    }
}