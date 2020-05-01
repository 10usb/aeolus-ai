class RailPathBuilder extends Task {
    path = [];
    offset = 0;
    signs = null;
    railType = null;

	constructor(path = []){
        this.path = path;
        this.offset = 0;
        this.signs = Signs();
	}

    function GetName(){
        return "RailPathBuilder"
    }

    function Append(path){
        this.path.extend(path);
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