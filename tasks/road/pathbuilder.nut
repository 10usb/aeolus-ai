/**
 * This task is mainly used as debugging. It's able to build (not yet fully
 * functional) from an array of tiles, the raw format what is obtained from an
 * A-star path finding. In the future it might also be used to build temperal
 * paths for trains to go over, while existing track segments get upgraded to
 * be more effectient.
 */
class Tasks_RoadPathBuilder extends Task {
    path = null;
    offset = 0;
    signs = null;
    roadType = null;

	constructor(roadType){
        this.roadType = roadType;
        this.path = [];
        this.offset = 2;
        this.signs = Signs();
	}

    function GetName(){
        return "Tasks_RoadPathBuilder"
    }

    function Append(path){
        this.path.extend(path);
    }

    function Finalize(){
        // Nothing to do here as this rail-processor doesn't hold anything back
    }

    function Run(){
        if(this.offset + 1 >= this.path.len()) {
            local from = this.path[this.offset - 1];
            local index = this.path[this.offset];
            Road.BuildRoad(from, index);
            signs.Clean();
            return false;
        }

        Road.SetCurrentRoadType(roadType);
        for(local count = 0; count < 10 && this.offset + 1 < this.path.len(); count++){
            local from = this.path[this.offset - 1];
            local index = this.path[this.offset];
            local to = this.path[this.offset + 1];

            local distance = Tile.GetDistanceManhattanToTile(index, to);

            if(distance > 1 && !AIBridge.IsBridgeTile(index)){
                local bridges = AIBridgeList_Length(distance + 1);
                foreach(bridge_id, _ in bridges){
                    Log.Info(AIBridge.GetName(bridge_id, Vehicle.VT_ROAD) + ": " + AIBridge.GetMinLength(bridge_id) + "-" + AIBridge.GetMaxLength(bridge_id));
                    if(AIBridge.BuildBridge(Vehicle.VT_ROAD, bridge_id, index, to))
                        break;
                }
            }

            Road.BuildRoad(from, index);
            this.offset++;
        }

        //Log.Info("PathBuilder: " + this.offset + " < " + this.path.len());
        if(this.offset + 1 < this.path.len()) return true;
        return this.Sleep(100);
    }
}