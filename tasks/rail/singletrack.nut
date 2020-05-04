/**
 * This task will try to connect two industies together by building a station
 * at each end with a track between it allowing just a single train on it.
 */
 class RailSingleTrack extends Task {
    source_id = null;
    destination_id = null;
    length = null;

    loading_station = null;
    processor = null;
    extender = null;
    offload_station = null;

	constructor(source_id, destination, length){
        this.source_id = source_id;
        this.destination = destination;
        this.length = length;
    }

    function GetName(){
        return "RailSingleTrack";
    }
    
    function Run(){
        return false;
    }
}