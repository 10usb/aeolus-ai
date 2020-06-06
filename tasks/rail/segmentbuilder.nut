/**
 * The task will automaticly build vector segments except the last one, leaving
 * that one open for optimization
 */
 class RailSegmentBuilder extends Task {
    railType = null;
    current = null;
    
	constructor(railType, root){
        this.railType = railType;
        this.current = root;
	}

    function GetName(){
        return "RailVectorBuilder";
    }

    function Run(){
        Rail.SetCurrentRailType(this.railType);

        while(this.current.next != null){
            this.Build();
            this.current = this.current.next;
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
        }
    }
}