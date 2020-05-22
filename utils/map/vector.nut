class MapVector {
	origin	= null;
	x		= 0;
	y		= 0;
}

function MapVector::Create(from, to){
	local vector	= MapVector();
	vector.origin	= MapVector.CreateOrigin(from);
	vector.x		= AIMap.GetTileX(to) - vector.origin.x;
	vector.y		= AIMap.GetTileY(to) - vector.origin.y;
	return vector;
}

function MapVector::CreateOrigin(tile){
	local origin	= MapVector();
	origin.origin	= null;
	origin.x		= AIMap.GetTileX(tile);
	origin.y		= AIMap.GetTileY(tile);
	return origin;
}

function MapVector::GetTileIndex(length){
	return AIMap.GetTileIndex(origin.x + (x * length), origin.y + (y * length));
}

function MapVector::GetSideTileIndex(length){
	return AIMap.GetTileIndex(origin.x + (y * length), origin.y + (x * length));
}

function MapVector::Normalize(){
	local max = abs(x) > abs(y) ? abs(x) : abs(y);
	x = x / max;
	y = y / max;
	return this;
}
function MapVector::Reverse(){
	x = -x;
	y = -y;
	return this;
}
function MapVector::ToString(){
	local value = x + "x" + y;
	if(origin!= null){
		value+= origin.ToString();
	}
	return value;
}