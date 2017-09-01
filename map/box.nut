class MapBox {
	center = null;
	minx = -1;
	maxx = -1;
	miny = -1;
	maxy = -1;

	constructor(){
		center = null;
	}
}

function MapBox::AddTile(index){
	local x	= AIMap.GetTileX(index);
	local y	= AIMap.GetTileY(index);

	if(this.center == null){
		minx = maxx = x;
		miny = maxy = y;
	}else{
		if(x < minx){
			minx = x;
		}else if(x > maxx){
			maxx = x;
		}

		if(y < miny){
			miny = y;
		}else if(y > maxy){
			maxy = y;
		}
	}

	this.center = AIMap.GetTileIndex((minx + maxx) / 2, (miny + maxy) / 2);
	//AILog.Info("box: [" + minx + "," + miny + "," + maxx + "," + maxy + "]" );
}

function MapBox::DistanceSquare(){
	return AIMap.DistanceSquare(AIMap.GetTileIndex(minx, miny), AIMap.GetTileIndex(maxx, maxy));
}