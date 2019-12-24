class RailVectorsVector {
	from	= null;
	to		= null;
	offset	= 0; // not 0 is diagonal
	height	= 0;
	pitch	= 0;
	length	= 0;
	jump	= false;

	constructor(){
		offset	= 0;
		height	= 0;
		pitch	= 0;
		length	= 0;
		jump	= false;
	}
}

function RailVectorsVector::Create(from, index, to){
	local vector = RailVectorsVector();

	vector.from		= from;
	vector.to		= index;
	vector.height	= MapPoint.GetMaxHeightAt(from, index);

	if(AIMap.GetTileX(vector.from)==AIMap.GetTileX(vector.to)){
		vector.offset	= AIMap.GetTileX(to) - AIMap.GetTileX(index);
	}else{
		vector.offset	= AIMap.GetTileY(to) - AIMap.GetTileY(index);
	}

	if(vector.offset!=0){
		vector.offset	= vector.offset / abs(vector.offset);
	}else{
		vector.pitch	= MapPoint.GetMaxHeightAt(index, to) - vector.height;
	}

	return vector;
}

function RailVectorsVector::ToPoint(){
	local point = MapPoint();
	point.from	= this.from;
	point.to	= this.to;
	return point;
}

function RailVectorsVector::GetPoint(length = -1){
	if(length < 0) length = this.length;

	local point	= MapPoint();

	local x		= AIMap.GetTileX(this.to);
	local y		= AIMap.GetTileY(this.to);
	local xo	= x - AIMap.GetTileX(this.from);
	local yo	= y - AIMap.GetTileY(this.from);

	if(offset == 0){
		if(xo != 0){
			point.from	= AIMap.GetTileIndex(x + xo * length, y);
			point.to	= AIMap.GetTileIndex(x + xo * (length + 1), y);
		}else{
			point.from	= AIMap.GetTileIndex(x, y + yo * length);
			point.to	= AIMap.GetTileIndex(x, y + yo * (length + 1));
		}
	}else{
		if(xo != 0){
			point.from	= AIMap.GetTileIndex(x + xo * (length / 2), y + offset * ((length + 1) / 2));
			point.to	= AIMap.GetTileIndex(x + xo * ((length + 1) / 2), y + offset * ((length + 2) / 2));
		}else{
			point.from	= AIMap.GetTileIndex(x + offset * ((length + 1) / 2), y + yo * (length / 2));
			point.to	= AIMap.GetTileIndex(x + offset * ((length + 2) / 2), y + yo * ((length + 1) / 2));
		}

	}

	return point;
}


function RailVectorsVector::Reverse(){
	local point = this.GetPoint();

	local vector	= RailVectorsVector();
	vector.from		= point.to;
	vector.to		= point.from;
	vector.length	= this.length;
	vector.height	= this.height;

	if(this.offset==0){
		vector.pitch	= -this.pitch;
	}else{
		vector.pitch	= 0;

		if((this.length&1)==1){
			vector.offset	= -this.offset;
		}else{
			if((AIMap.GetTileX(this.to) - AIMap.GetTileX(this.from)) + (AIMap.GetTileY(this.to) - AIMap.GetTileY(this.from)) == this.offset){
				vector.offset	= -this.offset;
			}else{
				vector.offset	= this.offset;
			}
		}
	}

	return vector;
}

function RailVectorsVector::Clone(){
	return clone this;
}