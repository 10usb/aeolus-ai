/**
 * This task must be initialized with a path of at least 1 tile and it will
 * build a track to its destination. It does this with search steps of the
 * specified size. It only builds 2/3 of each step to ensure that the joint of
 * each step is smoothed out. It stops building at the same distance from the
 * destination. It returns the tile index of its terminal.
 */
class RailPathExtender extends Task {
    path = null;

	constructor(path, destination, size){
        this.path = path;
    }

    function GetName(){
        return "RailPathExtender"
    }
    
    function Run(){
        return false;
    }
}