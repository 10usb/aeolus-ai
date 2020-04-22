/**
 * This task will find the best spot for a offload station around a destination
 * industry with a path connected to a path terminal
 */
 class RailOffLoadStation extends Task {
	constructor(destination_id, terminal){
    }

    function GetName(){
        return "RailOffLoadStation";
    }
    
    function Run(){
        return false;
    }
}