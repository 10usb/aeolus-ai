/**
 * This task will try to connect two industies together by building a station
 * at each end with a track between it allowing just a single train on it.
 */
 class RailSingleTrack extends Task {
    source_id = null;
    destination_id = null;
    length = null;
    railType = null;
    state = null;

    loading_station = null;
    processor = null;
    extender = null;
    offload_station = null;

    startDate = null;
    endDate = null;

	constructor(source_id, destination_id, length, railType){
        this.source_id = source_id;
        this.destination_id = destination_id;
        this.length = length;
        this.railType = railType;
        this.state = 0;
    }

    function GetName(){
        return "RailSingleTrack";
    }
    
    function Run(){
        switch(this.state){
            case 0: return FindLoadingStation();
            case 1: return BuildLoadingStation();
            case 2: return ExtendPath();
            case 3: return FindOffloadStation();
            case 4: return FinalizePath();
            case 5: return BuildOffloadStation();
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
    
    function BuildLoadingStation(){
        local path = this.loading_station.best.finder.GetPath();
        local x = Tile.GetX(path[0]);
        local y = Tile.GetY(path[0]);

        BuildStation(x, y, this.loading_station.best.offset);

        this.state++;
        return true;
    }
    
    function ExtendPath(){
        local path = this.loading_station.best.finder.GetPath();
        //this.processor = RailPathBuilder(this.railType);
        this.processor = RailPathOptimizer(this.railType);

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
    
    function BuildOffloadStation(){
        local path = this.offload_station.best.finder.GetPath();
        local x = Tile.GetX(path[0]);
        local y = Tile.GetY(path[0]);

        BuildStation(x, y, this.offload_station.best.offset);

        this.state++;
        return true;
    }

    function BuildStation(x, y, offset){
        local direction = null;
        
        if(offset.x > 0){
            x -= offset.x - 1;
            direction = Rail.RAILTRACK_NE_SW;
        }else if(offset.x < 0){
            direction = Rail.RAILTRACK_NE_SW;
        }

        if(offset.y > 0){
            y -= offset.y - 1;
            direction = Rail.RAILTRACK_NW_SE;
        }else if(offset.y < 0){
            direction = Rail.RAILTRACK_NW_SE;
        }

        local index = Tile.GetIndex(x, y);

        Rail.SetCurrentRailType(this.railType);
        if(!Rail.BuildRailStation(index, direction, 1, this.length, Station.STATION_NEW)){
            Log.Error("Failed to build station");
        }
    }
}