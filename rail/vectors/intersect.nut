class RailVectorsIntersect {
	straight	= null;
	diagonal	= null;

	constructor(){
	}
}

function RailVectorsIntersect::Create(straight, diagonal){
	if(AIMap.DistanceManhattan(straight.from, diagonal.GetPoint(0).to) >= AIMap.DistanceManhattan(straight.from, diagonal.from)) return null;

	if((AIMap.GetTileX(straight.to) - AIMap.GetTileX(straight.from))==0){
		diagonal.length = abs(AIMap.GetTileX(diagonal.to) - AIMap.GetTileX(straight.from)) * 2;
		if((AIMap.GetTileX(diagonal.to) - AIMap.GetTileX(diagonal.from))==0){
			diagonal.length--;
		}

		local point = diagonal.GetPoint();
		if(AIMap.GetTileY(diagonal.from) > AIMap.GetTileY(straight.from)){
			if(AIMap.GetTileY(point.to) < AIMap.GetTileY(straight.to)) return null;
		}else{
			if(AIMap.GetTileY(point.to) > AIMap.GetTileY(straight.to)) return null;
		}
		straight.length = AIMap.DistanceManhattan(straight.to, point.to);
	}else{
		diagonal.length = abs(AIMap.GetTileY(diagonal.to) - AIMap.GetTileY(straight.from)) * 2;
		if((AIMap.GetTileY(diagonal.to) - AIMap.GetTileY(diagonal.from))==0){
			diagonal.length--;
		}

		local point = diagonal.GetPoint();
		if(AIMap.GetTileX(diagonal.from) > AIMap.GetTileX(straight.from)){
			if(AIMap.GetTileX(point.to) < AIMap.GetTileX(straight.to)) return null;
		}else{
			if(AIMap.GetTileX(point.to) > AIMap.GetTileX(straight.to)) return null;
		}
		straight.length = AIMap.DistanceManhattan(straight.to, point.to);
	}


	local intersect = RailVectorsIntersect();
	intersect.straight = straight;
	intersect.diagonal = diagonal;
	return intersect;
}

function RailVectorsIntersect::CanBuild(){
	local index = 0;
	while(index <= this.straight.length){
		local point = this.straight.GetPoint(index);

		if(!AITile.IsBuildable(point.from)) return false;
		index++;
	}

	index = 0;
	while(index <= this.diagonal.length){
		local point = this.diagonal.GetPoint(index);

		if(!AITile.IsBuildable(point.from)) return false;
		index++;
	}


	local matrix = RailVectorsFinder.GetMatrix(this.straight);
	if(!matrix.LevelTo(this.straight.height)) return false;

	matrix = RailVectorsFinder.GetMatrix(this.diagonal);
	if(!matrix.LevelTo(this.diagonal.height)) return false;

	return true;
}