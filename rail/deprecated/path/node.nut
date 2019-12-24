class RailPathNode {
	index	 	= null;	// The tile index of this node
	x	 		= null;	// The tile x coordinate of this node
	y	 		= null;	// The tile y coordinate of this node
	forerunner	= null;	// The node pointing to
	towards		= 0;	// Direction value
	
	fromto		= 0;	// The combined from to direction value, the parent node will have if connected to this node
	speed		= 0;	// The speed at wich the train would go comming from the parent
	distance	= 0;	// The distance is has to travel over the parent node
	
	time		= 0;	// The total time it took to get to the border of this node
	extra		= 0;	// Extra time that would be lost due to not traveling at fullspeed
	
	constructor(index, forerunner){
		this.index	= index;
		this.x		= AIMap.GetTileX(index);
		this.y		= AIMap.GetTileY(index);
		this.forerunner	= forerunner;
		if(forerunner){
			this.towards = MapTile.GetDirection(index, forerunner.index);
			this.fromto = AITile.GetComplementSlope(this.towards) | this.forerunner.towards;
		}
	}
}

function RailPathNode::CanBuild(){
	switch(AITile.GetSlope(this.forerunner.index)){
		case AITile.SLOPE_FLAT: return true;
		case AITile.SLOPE_W:
			if(this.fromto==AITile.SLOPE_SEN) return true;
		break;
		case AITile.SLOPE_S:
			if(this.fromto==AITile.SLOPE_ENW) return true;
		break;
		case AITile.SLOPE_E:
			if(this.fromto==AITile.SLOPE_NWS) return true;
		break;
		case AITile.SLOPE_N:
			if(this.fromto==AITile.SLOPE_WSE) return true;
		break;
		case AITile.SLOPE_NW:
			if(this.forerunner.towards==AITile.SLOPE_NW || this.forerunner.towards==AITile.SLOPE_SE) return true;
		break;
		case AITile.SLOPE_SW:
			if(this.forerunner.towards==AITile.SLOPE_SW || this.forerunner.towards==AITile.SLOPE_NE) return true;
		break;
		case AITile.SLOPE_SE:
			if(this.forerunner.towards==AITile.SLOPE_SE || this.forerunner.towards==AITile.SLOPE_NW) return true;
		break;
		case AITile.SLOPE_NE:
			if(this.forerunner.towards==AITile.SLOPE_NE || this.forerunner.towards==AITile.SLOPE_SW) return true;
		break;
		case AITile.SLOPE_NWS:
			if(this.fromto==AITile.SLOPE_NWS) return true;
		break;
		case AITile.SLOPE_WSE:
			if(this.fromto==AITile.SLOPE_WSE) return true;
		break;
		case AITile.SLOPE_SEN:
			if(this.fromto==AITile.SLOPE_SEN) return true;
		break;
		case AITile.SLOPE_ENW:
			if(this.fromto==AITile.SLOPE_ENW) return true;
		break;
	}
	return false;
}

function RailPathNode::Calculate(increment){
	if(this.forerunner==null || this.forerunner.forerunner==null) return;
	
	switch(this.fromto){
		case AITile.SLOPE_ELEVATED:
			if(this.forerunner.fromto==AITile.SLOPE_ELEVATED){
				this.speed = this.forerunner.speed;
			}else{
				this.speed = this.forerunner.speed * 0.7;
			}
			this.distance = 44.0;
		break;
		case AITile.SLOPE_NWS:
			switch(this.forerunner.fromto){
				case AITile.SLOPE_SEN:
					this.speed = this.forerunner.speed;
				break;
				case AITile.SLOPE_ELEVATED:
					this.speed = this.forerunner.speed * 0.7;
				break;
				default:
					this.speed = this.forerunner.speed * 0.2;
				break;
			}
			
			this.distance = 31.1;
		break;
		case AITile.SLOPE_WSE:
			switch(this.forerunner.fromto){
				case AITile.SLOPE_ENW:
					this.speed = this.forerunner.speed;
				break;
				case AITile.SLOPE_ELEVATED:
					this.speed = this.forerunner.speed * 0.7;
				break;
				default:
					this.speed = this.forerunner.speed * 0.2;
				break;
			}
			this.distance = 31.1;
		break;
		case AITile.SLOPE_SEN:
			switch(this.forerunner.fromto){
				case AITile.SLOPE_NWS:
					this.speed = this.forerunner.speed;
				break;
				case AITile.SLOPE_ELEVATED:
					this.speed = this.forerunner.speed * 0.7;
				break;
				default:
					this.speed = this.forerunner.speed * 0.2;
				break;
			}
			this.distance = 31.1;
		break;
		case AITile.SLOPE_ENW:
			switch(this.forerunner.fromto){
				case AITile.SLOPE_WSE:
					this.speed = this.forerunner.speed;
				break;
				case AITile.SLOPE_ELEVATED:
					this.speed = this.forerunner.speed * 0.7;
				break;
				default:
					this.speed = this.forerunner.speed * 0.2;
					
				break;
			}
			this.distance = 31.1;
		break;
		default: throw("Unknown direction");
	}
	
	this.speed = Math.min(1, this.speed + (increment * this.distance));

	switch(AITile.GetSlope(this.forerunner.index)){
		case AITile.SLOPE_NW:
		case AITile.SLOPE_SW:
		case AITile.SLOPE_SE:
		case AITile.SLOPE_NE:
			if(AITile.GetMaxHeight(this.index) < AITile.GetMinHeight(this.forerunner.forerunner.index)){
				this.speed = Math.min(1, this.speed * 1.2);
			}else if(AITile.GetMaxHeight(this.index) > AITile.GetMinHeight(this.forerunner.forerunner.index)){
				this.speed = this.speed * 0.1;
			}
		break;
	}
	
	this.time = this.forerunner.time + (this.distance / this.speed);
	
	
	local temp = this.speed;
	this.extra = 0;
	while(temp < 1){
		temp = Math.min(1, temp + (increment * this.distance));
		this.extra+= (this.distance / temp) - this.distance;
	}
	
	this.extra+= this.time;
}