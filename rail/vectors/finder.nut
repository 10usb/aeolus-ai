require("vector.nut");
require("segment.nut");
require("intersect.nut");

class RailVectorsFinder {
	root	= null;

	constructor(){
		root	= null;
	}
}

function RailVectorsFinder::Parse(tiles){
	if(tiles.len() < 3) return false;

	this.root = RailVectorsSegment();
	this.root.vector = RailVectorsVector();
	this.root.vector.from	= tiles[0];
	this.root.vector.to		= tiles[1];
	this.root.vector.length	= -1;
	this.root.vector.height	= MapPoint.GetMaxHeightAt(tiles[0], tiles[1]);

	local index		= 2;
	local current	= this.root;

	do {
		local vector = current.vector;
		if(vector.pitch==0 && vector.jump==false){
			while(index < tiles.len()){
				local point = vector.GetPoint(vector.length + 1);
				if(point.to != tiles[index]) break;
				if(point.GetMaxHeight() != vector.height) break;
				vector.length++;
				index++;
			}
		}

		if(index < tiles.len()){
			local point = vector.GetPoint();
			current.next		= RailVectorsSegment();
			if(AIMap.DistanceManhattan(point.to, tiles[index]) > 1){
				current.next.vector = RailVectorsVector();
				current.next.vector.from	= point.from;
				current.next.vector.to		= point.to;
				current.next.vector.length	= AIMap.DistanceManhattan(point.to, tiles[index]);
				current.next.vector.height	= MapPoint.GetMaxHeightAt(point.from, point.to);
				current.next.vector.jump	= true;
				index++;
			}else{
				current.next.vector	= RailVectorsVector.Create(point.from, point.to, tiles[index]);
			}
			index++;
		}
		current = current.next;
	}while(current);
}

function RailVectorsFinder::Build(){
	local types = AIRailTypeList();
	types.Valuate(AIRail.IsRailTypeAvailable);
	types.KeepValue(1);

	AILog.Info("Using " + AIRail.GetName(types.Begin()));
	AIRail.SetCurrentRailType(types.Begin());

	local current = this.root;
	local signal = 0;

	while(current){
		local vector = current.vector;

		if(vector.jump){
			local ppoint = vector.GetPoint();

			local bridges = AIBridgeList_Length(vector.length+1);
			AIBridge.BuildBridge(AIVehicle.VT_RAIL, bridges.Begin(), vector.to, ppoint.from);
		}else{
			if(vector.pitch==0){
				local matrix = RailVectorsFinder.GetMatrix(vector);
				matrix.LevelTo(vector.height);
				matrix.MakeLevel();
			}

			local index = 0;
			local vpoint = vector.ToPoint();
			while(index <= vector.length){
				local ppoint = vector.GetPoint(index);

				if(AIRail.BuildRail(vpoint.from, vpoint.to, ppoint.to)){
					if(++signal > (vector.offset != 0 ? 5 : 3)){
						AIRail.BuildSignal(vpoint.to, vpoint.from, AIRail.SIGNALTYPE_NORMAL);
						signal = 0;
					}
				}else{
					signal = 3;
				}
				vpoint = ppoint;
				index++;
			}

		}

		current = current.next;
	}
}


function RailVectorsFinder::GetMatrix(vector){
	local index = 0;
	local vpoint = vector.ToPoint();
	local matrix = MapMatrix();

	while(index <= vector.length){
		local ppoint = vector.GetPoint(index);

		matrix.AddTile(vpoint.to, MapTile.GetDirection(vpoint.to, vpoint.from) | MapTile.GetDirection(vpoint.to, ppoint.to));

		vpoint = ppoint;
		index++;
	}

	return matrix;
}

function RailVectorsFinder::Optimize(){
	local current = this.root;
	local optimized = false;
	while(current){
		local end		= null;
		if(current.next!=null && current.vector.pitch==0 && current.vector.jump==false){
			end = current.next.next;
			while(end && end.vector.offset==current.vector.offset){
				end = end.next;
			}
		}

		local done = false;
		if(end && end.vector.pitch==0 && end.vector.jump==false && end.vector.height == current.vector.height){
			if(current.vector.offset==0){
				local intersect = RailVectorsIntersect.Create(current.vector.Clone(), end.vector.Reverse());
				if(intersect!=null && intersect.CanBuild()){
					current.vector	= intersect.straight;
					end.vector		= intersect.diagonal.Reverse();
					current.next	= end;
					done = true;
				}
			}else{
				local intersect = RailVectorsIntersect.Create(end.vector.Reverse(), current.vector.Clone());
				if(intersect!=null && intersect.CanBuild()){
					current.vector	= intersect.diagonal;
					end.vector		= intersect.straight.Reverse();
					current.next	= end;
					done = true;
				}
			}
		}

		if(!done){
			current = current.next;
		}else{
			optimized = true;
			//this.Build();
			//AIController.Sleep(10);
		}
	}
	return optimized;
}