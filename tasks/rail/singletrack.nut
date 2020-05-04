/**
 * This task will try to connect two industies together by building a station
 * at each end with a track between it allowing just a single train on it.
 */
 class RailSingleTrack extends Task {
    source_id = null;
    destination_id = null;
    length = null;
    state = null;

    loading_station = null;
    processor = null;
    extender = null;
    offload_station = null;

    startDate = null;
    endDate = null;

	constructor(source_id, destination_id, length){
        this.source_id = source_id;
        this.destination_id = destination_id;
        this.length = length;
        this.state = 0;
    }

    function GetName(){
        return "RailSingleTrack";
    }
    
    function Run(){
        switch(this.state){
            case 0: return FindLoadingStation();
            case 1: return ExtendPath();
            case 2: return FindOffloadStation();
            case 3: return FinalizePath();
        }

        this.endDate = Date.GetCurrentDate();
        Log.Info("Found route from " + Industry.GetName(source_id) + " to " + Industry.GetName(destination_id) + " took " + (this.endDate - this.startDate) + " days");
        return false;
    }
    
    function FindLoadingStation(){
        this.startDate = Date.GetCurrentDate();

        this.loading_station = RailLoadingStation(this.source_id, Industry.GetLocation(this.destination_id), this.length, 35);
        this.PushTask(this.loading_station);
        this.state++;
        return true;
    }
    
    function ExtendPath(){
        local path = this.loading_station.best.finder.GetPath();
        this.processor = RailPathBuilder();

        this.extender = RailPathExtender(path, Industry.GetLocation(this.destination_id), 35, this.processor);
        this.PushTask(this.extender);
        this.state++;
        return true;
    }
    
    function FindOffloadStation(){
        this.offload_station = RailOffloadStation(this.destination_id, this.extender.GetTerminal()[1], this.length);
        this.PushTask(this.offload_station);
        this.state++;
        return true;
    }
    
    function FinalizePath(){
        local path = this.offload_station.best.finder.GetPath();
        path.reverse();
        this.processor.Append(path.slice(1));
        this.processor.Finalize();
        this.PushTask(this.processor);
        this.state++;
        return true;
    }
}