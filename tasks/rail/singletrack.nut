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
    finalized = false;

	constructor(source_id, destination_id, length){
        this.source_id = source_id;
        this.destination_id = destination_id;
        this.length = length;
    }

    function GetName(){
        return "RailSingleTrack";
    }
    
    function Run(){
        if(this.loading_station == null){
            this.loading_station = RailLoadingStation(this.source_id, Industry.GetLocation(this.destination_id), this.length, 35);
            this.PushTask(this.loading_station);
            return true;
        }

        if(this.extender == null){
            local path = this.loading_station.best.finder.GetPath();
            this.processor = RailPathBuilder();

            this.extender = RailPathExtender(path, Industry.GetLocation(this.destination_id), 35, this.processor);
            this.PushTask(this.extender);
            return true;
        }

        if(this.offload_station == null){
            this.offload_station = RailOffloadStation(this.destination_id, this.extender.GetTerminal()[1], this.length);
            this.PushTask(this.offload_station);
            return true;
        }

        if(!finalized){
            local path = offload_station.best.finder.GetPath();
            path.reverse();
            this.processor.Append(path.slice(1));
            this.processor.Finalize();
            this.PushTask(this.processor);
            finalized = true;
            return true;
        }

        return false;
    }
}