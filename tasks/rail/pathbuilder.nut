/**
 * This task is mainly used as debugging. It's able to build (not yet fully
 * functional) from an array of tiles, the raw format what is obtained from an
 * A-star path finding. In the future it might also be used to build temperal
 * paths for trains to go over, while existing track segments get upgraded to
 * be more effectient.
 */
class RailPathBuilder extends Task {
    path = null;
    offset = 0;
    signs = null;
    railType = null;

	constructor(railType){
        this.railType = railType;
        this.path = [];
        this.offset = 1;
        this.signs = Signs();
	}

    function GetName(){
        return "RailPathBuilder"
    }

    function Append(path){
        this.path.extend(path);
    }

    function Finalize(){
        // Nothing to do here as this rail-processor doesn't hold anything back
    }

    function Run(){
        if(this.offset + 1 >= this.path.len()) {
            signs.Clean();
            return false;
        }

        if(offset == 0){
            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            railType = types.Begin();   
            offset++;     
            return true;
        }

        Rail.SetCurrentRailType(railType);
        for(local count = 0; count < 10 && this.offset + 1 < this.path.len(); count++){
            local from = this.path[this.offset - 1];
            local index = this.path[this.offset];
            local to = this.path[this.offset + 1];

            // this.signs.Build(index, "" + this.offset);

            local distance = Tile.GetDistanceManhattanToTile(index, to);
            if(distance == 1){
                Rail.BuildRail(from, index, to);
                this.offset++;
            }else{
                local vector = MapVector.Create(index, to).Normalize();
                
                // TODO Only build rail
                local start = vector.GetTileIndex(1);
                local end   = vector.GetTileIndex(distance - 1);

                Rail.BuildRail(from, index, start);

                local bridges = AIBridgeList_Length(distance - 1);
                AIBridge.BuildBridge(Vehicle.VT_RAIL, bridges.Begin(), start, end);

                if(this.offset + 2 < this.path.len()){
                    Rail.BuildRail(end, to, this.path[this.offset + 2]);
                }

                this.offset+=2;
            }
        }

        //Log.Info("PathBuilder: " + this.offset + " < " + this.path.len());
        if(this.offset + 1 < this.path.len()) return true;
        return this.Sleep(100);
    }
}