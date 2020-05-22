require("dot.nut");

class MapMatrix {
	dots	= null;
	inner	= null;
	outer	= null;

	constructor(){
		dots  = {};
		inner = AIList();
		outer = AIList();
	}
}

function MapMatrix::GetDot(index){
	if(!this.dots.rawin(index)){
		this.dots.rawset(index, MapDot(index));
	}
	return this.dots.rawget(index);
}

function MapMatrix::AddRectangle(tile, width, height){
	local minx = AIMap.GetTileX(tile);
	local miny = AIMap.GetTileY(tile);
	local maxx = minx + width;
	local maxy = miny + height;

	local list = AIList();

	for(local y=miny; y<=maxy; y++){
		for(local x=minx; x<=maxx; x++){
			local index = AIMap.GetTileIndex(x, y);
			if(!this.dots.rawin(index)){
				this.dots.rawset(index, MapDot(index));
			}
			if(x==minx || x==maxx || y==miny || y==maxy){
				outer.AddItem(index, 0);
			}else{
				inner.AddItem(index, 0);
			}
		}
	}
}

function MapMatrix::AddTile(tile, slope = 0){
	local x = AIMap.GetTileX(tile);
	local y = AIMap.GetTileY(tile);

	if(slope==0) slope = AITile.SLOPE_ELEVATED;

	if(slope & AITile.SLOPE_N){
		local index = AIMap.GetTileIndex(x, y);
		if(!this.dots.rawin(index)){
			this.dots.rawset(index, MapDot(index));
			inner.AddItem(index, 0);
		}
	}
	if(slope & AITile.SLOPE_W){
		local index = AIMap.GetTileIndex(x + 1, y);
		if(!this.dots.rawin(index)){
			this.dots.rawset(index, MapDot(index));
			inner.AddItem(index, 0);
		}
	}
	if(slope & AITile.SLOPE_E){
		local index = AIMap.GetTileIndex(x, y + 1);
		if(!this.dots.rawin(index)){
			this.dots.rawset(index, MapDot(index));
			inner.AddItem(index, 0);
		}
	}
	if(slope & AITile.SLOPE_S){
		local index = AIMap.GetTileIndex(x + 1, y + 1);
		if(!this.dots.rawin(index)){
			this.dots.rawset(index, MapDot(index));
			inner.AddItem(index, 0);
		}
	}
}

function MapMatrix::GetHeights(){
	local tiles = AIList();

	foreach(index, dot in this.dots){
		tiles.AddItem(index, dot.height);
	}

	return tiles;
}

function MapMatrix::Translate(index, x, y){
	return AIMap.GetTileIndex(AIMap.GetTileX(index) + x, AIMap.GetTileY(index) + y);
}

function MapMatrix::Level(){
	local selection = AIList();
	selection.AddList(this.inner);
	selection.AddList(this.outer);

	local total = 0.0;
	foreach(index, dummy in selection){
		total += this.GetDot(index).height;
	}

	local average = Math.round(total / selection.Count());

	local level = this.LevelTo(average);
	if(level) return true;

	local min = average;
	local max = average;
	foreach(index, dummy in outer){
		min = Math.min(min, this.GetDot(index).height);
		max = Math.max(max, this.GetDot(index).height);
	}

	if((max-min) > 1) return false;

	this.dots.clear();

	if(max > average){
		return this.LevelTo(max);
	}else if(min < average){
		return this.LevelTo(min);
	}
	return false;
}

function MapMatrix::LevelTo(height){
	local selection = AIList();
	selection.AddList(this.inner);
	selection.AddList(this.outer);

	foreach(index, dummy in selection){
		local dot = this.GetDot(index);
		local failed = false;

		if(dot.height > height){
			do {
				if(!this.Lower(index)){
					failed = true;
					break;
				}
			}while(dot.height > height);
			if(failed) break;
		}else if(dot.height < height){
			do {
				if(!this.Raise(index)){
					failed = true;
					break;
				}
			}while(dot.height < height);
			if(failed) break;
		}
	}

	local level = true;

	foreach(index, dummy in this.inner){
		if(this.GetDot(index).height != height){
			level = false;
			break;
		}
	}
	if(level){
		foreach(index, dummy in this.outer){
			if(this.GetDot(index).height > height || this.GetDot(index).height < (height - 1)){
				level = false;
			}
		}
		if(level) return true;
	}
	return false;
}

function MapMatrix::MakeLevel(){
	local selection = AIList();
	selection.AddList(this.inner);
	selection.AddList(this.outer);

	local level = false;
	local limit = 30;
	while(!level && limit--){
		level = true;
		selection.Valuate(AIBase.RandRangeItem, selection.Count() * 3);

		foreach(index, dummy in selection){
			local dot = this.GetDot(index);
			local currentHeight = dot.getCurrentHeight();
			if(dot.height < currentHeight){
				AITile.LowerTile(index, AITile.SLOPE_N);
				level = false
			}else if(dot.height > currentHeight){
				AITile.RaiseTile(index, AITile.SLOPE_N);
				level = false
			}
		}
	}
}


function MapMatrix::Raise(index){
	local dot = this.GetDot(index);

	if(dot.locked) return false;
	if(this.dots.len() > 200) return false;

	local neighbor = null;
	neighbor = this.GetDot(MapMatrix.Translate(index, -1, 0));
	if(neighbor.height < dot.height){
		if(!this.Raise(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 0, -1));
	if(neighbor.height < dot.height){
		if(!this.Raise(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 1, 0));
	if(neighbor.height < dot.height){
		if(!this.Raise(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 0, 1));
	if(neighbor.height < dot.height){
		if(!this.Raise(neighbor.index)) return false;
	}

	dot.height++;
	return true;
}

function MapMatrix::Lower(index){
	local dot = this.GetDot(index);

	if(dot.locked) return false;
	if(this.dots.len() > 200) return false;

	local neighbor = null;
	neighbor = this.GetDot(MapMatrix.Translate(index, -1, 0));
	if(neighbor.height > dot.height){
		if(!this.Lower(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 0, -1));
	if(neighbor.height > dot.height){
		if(!this.Lower(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 1, 0));
	if(neighbor.height > dot.height){
		if(!this.Lower(neighbor.index)) return false;
	}

	neighbor = this.GetDot(MapMatrix.Translate(index, 0, 1));
	if(neighbor.height > dot.height){
		if(!this.Lower(neighbor.index)) return false;
	}

	dot.height--;
	return true;
}

function MapMatrix::getDifferance(index, x, y){
	if(x!=0 || y!=0){
		index = AIMap.GetTileIndex(AIMap.GetTileX(index) + x, AIMap.GetTileY(index) + y);
	}
	if(!this.dots.rawin(index)) return 0;
	return this.dots.rawget(index).getDifferance();
}

function MapMatrix::GetCosts(){
	local total = 0;
	foreach(dot in this.dots){
		total+= Math.abs(dot.getDifferance()) * AITile.GetBuildCost(AITile.BT_TERRAFORM);


		if(dot.getDifferance()!=0
			|| abs(this.getDifferance(dot.index, 1, 0))!=0
			|| abs(this.getDifferance(dot.index, 0, 1))!=0
			|| abs(this.getDifferance(dot.index, 1, 1))!=0){

			if(AITile.IsWaterTile(dot.index) && AITile.GetMinHeight(dot.index) == 0){
				total+= 7599;
			}else if(AITile.IsCoastTile(dot.index) && AITile.GetMinHeight(dot.index) == 0){
				switch(AITile.GetSlope(dot.index)){
					case AITile.SLOPE_NW:
					case AITile.SLOPE_SW:
					case AITile.SLOPE_SE:
					case AITile.SLOPE_NE:
					case AITile.SLOPE_EW:
					case AITile.SLOPE_NS:
						total+= AITile.GetBuildCost(AITile.BT_CLEAR_GRASS);
					break;
					default:
						total+= 7599;
					break;
				}
			}else if(AITile.IsFarmTile(dot.index)){
				total+= AITile.GetBuildCost(AITile.BT_CLEAR_FIELDS);
			}else if(AITile.IsRockTile(dot.index)){
				total+= AITile.GetBuildCost(AITile.BT_CLEAR_ROCKY);
			}else if(AITile.IsRoughTile(dot.index)){
				total+= AITile.GetBuildCost(AITile.BT_CLEAR_ROUGH);
			}else{
				total+= AITile.GetBuildCost(AITile.BT_CLEAR_GRASS);
			}
		}

	}

	return total;
}
