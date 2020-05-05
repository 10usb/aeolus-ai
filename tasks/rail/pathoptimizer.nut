/**
 * This rail processor task will try to optimize the path received before
 * constructing it. First it will transform the array of tiles into vectors.
 * These vectors can then be aligned opon each other and tested. Thus removeing
 * the vectors inbetween, giving a more smooth rail.
 */
class RailPathOptimizer extends Task {
	constructor(){
	}

    function GetName(){
        return "RailPathOptimizer"
    }

    function Append(path){
    }

    function Finalize(){
    }

    function Run(){
        return false;
    }
}