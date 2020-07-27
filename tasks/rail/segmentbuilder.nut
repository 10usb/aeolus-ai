/**
 * The task will automaticly build vector segments except the last one, leaving
 * that one open for optimization
 * TODO: Added option to not build the last 30 tiles or so, when not finalized
 */
 class RailSegmentBuilder extends Task {
    railType = null;
    current = null;
    close = null;
    
	constructor(railType, root, close){
        this.railType = railType;
        this.current = root;
        this.close = close;
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
        Rail.SetCurrentRailType(this.railType);

        while(this.current.next != null){
            this.Build();
            this.current = this.current.next;
        }

        if(this.close){
            this.Build();
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