/**
 * This task will find the best spot for a loading station around a source
 * industry with an initial path pointing to a destination tile
 */
 class RailLoadingStation extends Task {
	constructor(source_id, destination, length, size){
    }

    function GetName(){
        return "RailLoadingStation";
    }
    
    function Run(){
        return false;
    }
}