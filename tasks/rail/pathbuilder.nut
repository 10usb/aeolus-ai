class RailPathBuilder extends Task {
    path = null;
    index = 0;
    signs = null;

	constructor(path){
        this.path = path;
        this.index = 1;
        this.signs = Signs();
	}
}

function RailPathBuilder::GetName(){
    return "RailPathBuilder"
}

function RailPathBuilder::Run(){
    if(this.index >= this.path.len()) {
        signs.Clean();
        return false;
    }

    for(local count = 0; count < 10 && this.index < this.path.len(); count++){
        this.signs.Build(this.path[this.index++], "" + this.index);
    }

    if(this.index < this.path.len()) return true;
    return this.Sleep(100);
}


function RailPathBuilder::GetRailTrack(from, to){
	switch(from){
		case AITile.SLOPE_NW:
			switch(to){
				case AITile.SLOPE_SW: return AIRail.RAILTRACK_NW_SW;
				case AITile.SLOPE_SE: return AIRail.RAILTRACK_NW_SE;
				case AITile.SLOPE_NE: return AIRail.RAILTRACK_NW_NE;
			}
		break;
		case AITile.SLOPE_SW:
			switch(to){
				case AITile.SLOPE_NW: return AIRail.RAILTRACK_NW_SW;
				case AITile.SLOPE_SE: return AIRail.RAILTRACK_SW_SE;
				case AITile.SLOPE_NE: return AIRail.RAILTRACK_NE_SW;
			}
		break;
		case AITile.SLOPE_SE:
			switch(to){
				case AITile.SLOPE_NW: return AIRail.RAILTRACK_NW_SE;
				case AITile.SLOPE_SW: return AIRail.RAILTRACK_SW_SE;
				case AITile.SLOPE_NE: return AIRail.RAILTRACK_NE_SE;
			}
		break;
		case AITile.SLOPE_NE:
			switch(to){
				case AITile.SLOPE_NW: return AIRail.RAILTRACK_NW_NE;
				case AITile.SLOPE_SW: return AIRail.RAILTRACK_NE_SW;
				case AITile.SLOPE_SE: return AIRail.RAILTRACK_NE_SE;
			}
		break;
	}
	throw("Error");
}