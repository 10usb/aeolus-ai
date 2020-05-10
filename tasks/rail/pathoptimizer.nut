/**
 * This rail processor task will try to optimize the path received before
 * constructing it. First it will transform the array of tiles into vectors.
 * These vectors can then be aligned opon each other and tested. Thus removeing
 * the vectors inbetween, giving a more smooth rail.
 */
class RailPathOptimizer extends Task {
    railType = null;
    preceding = null;
    
	constructor(railType){
        this.railType = railType;
        this.preceding = null;
	}

    function GetName(){
        return "RailPathOptimizer";
    }

    function Append(path){
        if(this.preceding){
            this.preceding.extend(path);
            path = this.preceding;
        }

        local vectors = RailVectorSegment.Parse(path);
        RailVectorBuilder.BuildChain(vectors);

        this.preceding = path.slice(-2);
    }

    function Finalize(){
    }

    function Run(){
        return false;
    }
}