/**
 * The task will automaticly build vector segments except the last one, leaving
 * that one open for optimization
 * TODO: Added option to not build the last 30 tiles or so, when not finalized
 */
 class RailSegmentBuilder extends Task {
    railType = null;
    current = null;
    close = null;
    leaveOpen = null;
    
	constructor(railType, root, close, leaveOpen){
        this.railType = railType;
        this.current = root;
        this.close = close;
        this.leaveOpen = leaveOpen;
	}

    function GetName(){
        return "RailVectorBuilder";
    }

    function GetNext(){
        return this.current;
    }

    function Finalize(){
        this.close = true;
    }

    function Run(){
        local pointer = this.current;
        while(pointer.next != null) pointer = pointer.next;
        local tail = pointer.rail.GetTileIndex(pointer.index, pointer.origin);


        Rail.SetCurrentRailType(this.railType);

        if(this.close){
            while(this.current != null){
                this.Build();
                this.current = this.current.next;
            }
        }else{
            while(this.current.next != null){
                if(this.current.rail != null){
                    local index = this.current.rail.GetTileIndex(this.current.index, this.current.origin);
                    if(Tile.GetDistance(index, tail) < this.leaveOpen) break;
                }

                this.Build();
                this.current = this.current.next;
            }
        }
        
        return false;
    }

    function Build(){
        if(this.current.rail != null){
            //signs.Build(current.index, "rail");
            RailVectorBuilder.BuildRail(this.current.rail, this.current.index, this.current.origin);
        }else if(this.current.bridge != null){
            //signs.Build(current.index, "bridge");
            RailVectorBuilder.BuildBridge(this.current.bridge, this.current.index, this.current.origin);
        }else{
            Log.Info("Building someting i guess...");
        }
    }
}