class Rail extends AIRail {

}

function Rail::GetRailTrack(from, to){
	switch(from){
		case Tile.SLOPE_NW:
			switch(to){
				case Tile.SLOPE_SW: return Rail.RAILTRACK_NW_SW;
				case Tile.SLOPE_SE: return Rail.RAILTRACK_NW_SE;
				case Tile.SLOPE_NE: return Rail.RAILTRACK_NW_NE;
			}
		break;
		case Tile.SLOPE_SW:
			switch(to){
				case Tile.SLOPE_NW: return Rail.RAILTRACK_NW_SW;
				case Tile.SLOPE_SE: return Rail.RAILTRACK_SW_SE;
				case Tile.SLOPE_NE: return Rail.RAILTRACK_NE_SW;
			}
		break;
		case Tile.SLOPE_SE:
			switch(to){
				case Tile.SLOPE_NW: return Rail.RAILTRACK_NW_SE;
				case Tile.SLOPE_SW: return Rail.RAILTRACK_SW_SE;
				case Tile.SLOPE_NE: return Rail.RAILTRACK_NE_SE;
			}
		break;
		case Tile.SLOPE_NE:
			switch(to){
				case Tile.SLOPE_NW: return Rail.RAILTRACK_NW_NE;
				case Tile.SLOPE_SW: return Rail.RAILTRACK_NE_SW;
				case Tile.SLOPE_SE: return Rail.RAILTRACK_NE_SE;
			}
		break;
	}
	throw("Error");
}