/**
 * This task will try to connect two industies together by building a station
 * at each end with a track between it allowing just a single train on it.
 */
 class RailVectorOptimizer extends Task {
    root = null;

	constructor(root){
        this.root = root;
    }

    function GetName(){
        return "RailVectorOptimizer";
    }
    
    function Run(){
        return false;
    }
}