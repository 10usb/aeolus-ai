require("node.nut");
require("queue.nut");

class RailAstarFinder {
	endpoints	= null;
	exclusions	= null;
	trail		= null;

	queue		= null;
	nodes		= null;

	box			= null;

	maxdistance = null;
	maxvalue	= null;
	center		= null;

	path		= null;

	signs		= null;

	rail_types	= null;
	cost		= null;

	constructor(){
		this.signs		= Signs();

		this.queue		= RailAstarQueue();
		this.nodes		= {};

		this.endpoints	= AIList();
		this.exclusions	= AIList();
		this.trail		= AIList();
		this.box		= MapBox();

		rail_types		= AIList();

		this.cost = {
			normal = {
				tile	= 10,
				slope	= 300,
				coast	= 100,
				bridge	= {
					tile 		= 10,
					increment	= 5
				}
			},
			rail = {
				tile	= 5,
				slope	= 150,
				coast	= 50,
				bridge	= {
					tile 		= 5,
					increment	= 0
				}
				leave	= 800,
			}
		}
	}
}


function RailAstarFinder::AddStartpoint(point){
	if(!this.nodes.rawin(point.to)){
		local node		= RailAstarNode();
		node.index		= point.to;
		node.towards	= point.from;
		node.value		= 0;
		node.fixed		= true;

		this.nodes.rawset(node.index, node);
		this.queue.Add(node);

		this.box.AddTile(point.from);
		this.box.AddTile(point.to);


		if(!this.exclusions.HasItem(point.from)){
			this.exclusions.AddItem(point.from, 0);
		}

		if(!this.trail.HasItem(point.to)){
			this.trail.AddItem(point.to, point.from);
		}
	}
}

function RailAstarFinder::AddEndpoint(point){
	if(!this.endpoints.HasItem(point.from)){
		this.endpoints.AddItem(point.from, 0);

		if(!this.exclusions.HasItem(point.to)){
			this.exclusions.AddItem(point.to, 0);
		}

		if(!this.trail.HasItem(point.from)){
			this.trail.AddItem(point.from, point.to);
		}

		this.box.AddTile(point.from);
		this.box.AddTile(point.to);
	}
}

function RailAstarFinder::SetRailTypes(rail_types){
	this.rail_types = rail_types;
}

function RailAstarFinder::GetNode(index){
	if(!this.nodes.rawin(index)){
		local node = RailAstarNode();
		node.index = index;
		node.value = -1;
		this.nodes.rawset(index, node);
	}
	return this.nodes.rawget(index);
}

/**
 * Checks if the value is better
 */
function RailAstarFinder::CheckValue(index, towards, value){
	if(value > this.maxvalue) return;
	if(this.exclusions.HasItem(index)) return;
	if(AIMap.DistanceSquare(index, this.center) > this.maxdistance) return;

	local node = this.GetNode(index);
	if(node.fixed) return;

	if(node.value < 0){
		node.towards	= towards;
		node.value		= value;
		this.queue.Add(node);

		if(this.endpoints.HasItem(index)){
			this.endpoints.SetValue(index, node.value.tointeger());
			this.maxvalue = node.value;
		}

		// this.signs.Build(index, "" + value);
	}else if(node.value > value){
		node.towards	= towards;
		node.value		= value;
		// Requeue
		this.queue.Add(node);

		if(this.endpoints.HasItem(index)){
			this.endpoints.SetValue(index, node.value.tointeger());
			this.maxvalue = node.value;
		}

		//this.signs.Build(index, "#" + value);
	}
}

function RailAstarFinder::Init(){
	this.center			= this.box.center;
	this.maxdistance	= 200 + (this.box.DistanceSquare() * 0.6);
	this.maxvalue		= (this.cost.normal.tile*10) + (sqrt(this.maxdistance) * (this.cost.normal.tile*40));

	this.signs.Build(this.center, "Center");
}

function RailAstarFinder::Search(){
	// making sure a valid type is selected
	local types = AIRailTypeList();
	types.Valuate(AIRail.IsRailTypeAvailable);
	types.KeepValue(1);
	AIRail.SetCurrentRailType(types.Begin());

	while(this.Step());

	AILog.Info("Done");
	signs.Clean();


	foreach(index, dummy in this.endpoints){
		if(this.nodes.rawin(index)){
			local node = this.nodes.rawget(index);
			this.endpoints.SetValue(index, node.value.tointeger());
		}
	}

	this.endpoints.Sort(AIList.SORT_BY_VALUE, true);
	this.endpoints.KeepAboveValue(0);

	this.path = [];
	foreach(tile, dummy in this.endpoints){
		if(this.nodes.rawin(tile)){
			local current = this.nodes.rawget(tile);
			if(this.trail.HasItem(tile)) this.path.insert(0, this.trail.GetValue(tile));

			while(current!=null){
				this.path.insert(0, current.index);

				this.signs.Build(current.index, "" + this.path.len());

				if(AIMap.DistanceManhattan(current.index, current.towards) > 1){
					local vector = MapVector.Create(current.index, current.towards);
					vector.Normalize();
					this.path.insert(0, vector.GetTileIndex(1));
					this.path.insert(0, vector.GetTileIndex(AIMap.DistanceManhattan(current.index, current.towards) - 1));
				}

				if(this.nodes.rawin(current.towards)){
					current = this.nodes.rawget(current.towards);
				}else{
					this.path.insert(0, current.towards);
					current = null;
				}
			}
			break;
		}
	}
	AILog.Info("Made path");
	this.nodes = null;
	//signs.Clean();

	return this.path;
}

function RailAstarFinder::Step(){
	if(this.queue.Count() <= 0) return false;

	local node = this.queue.Poll();

	if(AIMap.DistanceManhattan(node.index, node.towards) > 1){
		// Node is a bridge or tunnel
		if(this.rail_types.HasItem(AIRail.GetRailType(node.index))){
			// Current node has compatible rails so other cost values might apply
			AILog.Info("We made it!");
		}else{
			// Check if direction + 1 is blocked one step back for bridge or tunnel check
			this.StepBridge(node);
		}
	}else{
		if(this.rail_types.HasItem(AIRail.GetRailType(node.index))){
			// Current node has compatible rails so other cost values might apply & limited directions (no crossings)
			this.StepRail(node);
		}else{
			this.StepNormal(node);
		}
	}
	return true;
}

function RailAstarFinder::StepRail(node){
	if(AITile.GetSlope(node.index)!=AITile.SLOPE_FLAT){
		//this.StepSlope(node);
	}else{
		// Normal checks forward, left and right
		// - Check for bridges
		// - Check for rail connections
		local vector = MapVector.Create(node.index, node.towards);
		local connected = RailAstarFinder.IsConnected(node.index, node.towards);
		this.CheckRailJunction(connected, node.index, vector.GetTileIndex(-1), node.value, true);
		this.CheckRailJunction(connected, node.index, vector.GetSideTileIndex(1), node.value, false);
		this.CheckRailJunction(connected, node.index, vector.GetSideTileIndex(-1), node.value, false);
	}
}

function RailAstarFinder::CheckRailJunction(connected, origin, index, value, straight){
	if(!AITile.IsBuildable(index) && this.rail_types.HasItem(AIRail.GetRailType(index)) && AICompany.IsMine(AITile.GetOwner(index)) && !AIRail.IsRailStationTile(index) && !RailAstarFinder.HasSignal(index, origin)){
		if(AIBridge.IsBridgeTile(index)){
			local vector = MapVector.Create(index, AIBridge.GetOtherBridgeEnd(index)).Normalize();
			if(vector.GetTileIndex(-1)==origin){

				local length = AIMap.DistanceManhattan(index, AIBridge.GetOtherBridgeEnd(index));

				local cost = connected ? this.cost.normal : this.cost.rail;

				local addition = cost.bridge.tile;
				for(local i=0; i<length; i+=1){
					value += addition;
					addition += cost.bridge.increment;
				}

				if(!(AITile.GetSlope(index) == AITile.SLOPE_SW
				|| AITile.GetSlope(index) == AITile.SLOPE_NE
				|| AITile.GetSlope(index) == AITile.SLOPE_SE
				|| AITile.GetSlope(index) == AITile.SLOPE_NW)){
					value += cost.slope;
				}

				local vindex = vector.GetTileIndex(length);
				if(!(AITile.GetSlope(vindex) == AITile.SLOPE_SW
				|| AITile.GetSlope(vindex) == AITile.SLOPE_NE
				|| AITile.GetSlope(vindex) == AITile.SLOPE_SE
				|| AITile.GetSlope(vindex) == AITile.SLOPE_NW)){
					value += cost.slope;
				}

				this.CheckValue(vector.GetTileIndex(length + 1), origin, value);


			}
		}else{
			if(connected){
				if(RailAstarFinder.IsConnected(index, origin) && RailAstarFinder.IsConnected(origin, index)){
					this.CheckValue(index, origin, value + this.cost.rail.tile);
				}else{
					this.CheckValue(index, origin, value + this.cost.rail.tile + this.cost.rail.leave);
				}
			}else{
				if(straight){
					if(!(AIRail.GetRailTracks(origin) & (AIRail.RAILTRACK_NW_SE | AIRail.RAILTRACK_NE_SW))){
						this.CheckValue(index, origin, value + this.cost.normal.tile);
					}
				}else{
					this.CheckValue(index, origin, value + this.cost.normal.tile);
				}
			}
		}
	}else if(AITile.IsBuildable(index)){
		if(connected){
			this.CheckValue(index, origin, value + this.cost.rail.tile + this.cost.rail.leave);
		}else{
			if(straight){
				if(!(AIRail.GetRailTracks(origin) & (AIRail.RAILTRACK_NW_SE | AIRail.RAILTRACK_NE_SW))){
					this.CheckValue(index, origin, value + this.cost.normal.tile);
				}
			}else{
				this.CheckValue(index, origin, value + this.cost.normal.tile);
			}
		}
	}
}

function RailAstarFinder::StepBridge(node){

	if(AITile.GetSlope(node.index)!=AITile.SLOPE_FLAT){
		this.StepSlope(node);
	}else{
		// Normal checks forward, left and right
		// - Check for bridges
		// - Check if direction + 1 is blocked one step back for bridge or tunnel check
		// - Check for rail connections
		local vector = MapVector.Create(node.index, node.towards).Normalize().Reverse();
		this.CheckNormal(node.index, vector.GetTileIndex(1), node.value, this.cost.normal);
		//this.CheckBridge(vector.GetTileIndex(-1), node.index, node.value, this.cost.normal);
		this.CheckNormal(node.index, vector.GetSideTileIndex(1), node.value, this.cost.normal);
		this.CheckNormal(node.index, vector.GetSideTileIndex(-1), node.value, this.cost.normal);
	}
}

function RailAstarFinder::StepNormal(node){
	if(AITile.GetSlope(node.index)!=AITile.SLOPE_FLAT){
		this.StepSlope(node);
	}else{
		// Normal checks forward, left and right
		// - Check for bridges
		// - Check for rail connections
		local vector = MapVector.Create(node.index, node.towards);
		this.CheckNormal(node.index, vector.GetTileIndex(-1), node.value, this.cost.normal);
		this.CheckNormal(node.index, vector.GetSideTileIndex(1), node.value, this.cost.normal);
		this.CheckNormal(node.index, vector.GetSideTileIndex(-1), node.value, this.cost.normal);
	}
}

function RailAstarFinder::StepSlope(node){
	// Check wich direction is posible, forward, left or right?
	// - Check for bridge
	// - Check for rail connection
	local vector = MapVector.Create(node.index, node.towards).Normalize().Reverse();
	local direction = MapTile.GetDirection(node.index, vector.GetTileIndex(-1));
	if(direction == AITile.GetSlope(node.index) || direction == AITile.GetComplementSlope(AITile.GetSlope(node.index))){
		// Streight up or down
		this.CheckSlope(node.index, vector.GetTileIndex(1), node.value, this.cost.normal);
	}else{
		if(direction & AITile.GetSlope(node.index)){
			if((direction & AITile.GetSlope(node.index)) == direction){
				local side = vector.GetSideTileIndex(1);
				if((MapTile.GetDirection(node.index, side) & AITile.GetSlope(node.index)) == MapTile.GetDirection(node.index, side)){
					this.CheckRail(node.index, side, node.value, this.cost.normal);
				}

				side = vector.GetSideTileIndex(-1);
				if((MapTile.GetDirection(node.index, side) & AITile.GetSlope(node.index)) == MapTile.GetDirection(node.index, side)){
					this.CheckRail(node.index, side, node.value, this.cost.normal);
				}
			}
		}else{
			// Towards is flat
			local side = vector.GetSideTileIndex(1);
			if((MapTile.GetDirection(node.index, side) & AITile.GetSlope(node.index)) == 0){
				this.CheckRail(node.index, side, node.value, this.cost.normal);
			}

			side = vector.GetSideTileIndex(-1);
			if((MapTile.GetDirection(node.index, side) & AITile.GetSlope(node.index)) == 0){
				this.CheckRail(node.index, side, node.value, this.cost.normal);
			}
		}
	}
}

function RailAstarFinder::CheckNormal(origin, index, value, cost){
	this.CheckRail(origin, index, value, cost);
	this.CheckBridge(origin, index, value, cost);
}

/**
 * Checks if a new rail can be build
 */
function RailAstarFinder::CheckRail(origin, index, value, cost){
	if(AITile.IsBuildable(index)){
		this.CheckValue(index, origin, value + cost.tile);
	}else if(this.rail_types.HasItem(AIRail.GetRailType(index)) && AICompany.IsMine(AITile.GetOwner(index)) && !AIRail.IsRailStationTile(index) && !RailAstarFinder.HasSignal(index, origin)){
		if(AIBridge.IsBridgeTile(index)){

		}else{
			this.CheckValue(index, origin, value + cost.tile);
		}
	}

}

/**
 * Checks if a new rail can be build
 */
function RailAstarFinder::CheckSlope(origin, index, value, cost){
	if(AITile.IsBuildable(index)){
		this.CheckValue(index, origin, value + cost.slope);
	}
}
/**
 * Checks if a bridge could be build
 */
function RailAstarFinder::CheckBridge(origin, index, value, cost){
	if(AITile.IsBuildable(index)){
		local vector	= MapVector.Create(origin, index);
		local vindex	= vector.GetTileIndex(2);

		// Could make a bridge over it.
		if(AIRoad.IsRoadTile(vindex) || AIRail.IsRailTile(vindex) || AITile.IsWaterTile(vindex)){
			//this.signs.Build(origin, "Bridge");
			//this.signs.Build(vindex, "Road");
			local length = 3;
			do {
				vindex = vector.GetTileIndex(length);

				if(AITile.IsBuildable(vindex) && !AIRoad.IsRoadTile(vindex)){
					vindex = vector.GetTileIndex(length + 1);

					if(AITile.IsBuildable(vindex) && !AIRoad.IsRoadTile(vindex)){
						local bridges = AIBridgeList_Length(AIMap.DistanceManhattan(index, vector.GetTileIndex(length)) + 1);
						local valid = false;
						{
							local mode = AITestMode();
							valid = AIBridge.BuildBridge(AIVehicle.VT_RAIL, bridges.Begin(), index, vector.GetTileIndex(length));
							mode = null;
						}

						if(valid){
							local addition = cost.bridge.tile;
							for(local i=0; i<length; i+=1){
								value += addition;
								addition += cost.bridge.increment;
							}

							if(!(AITile.GetSlope(index) == AITile.SLOPE_SW
							|| AITile.GetSlope(index) == AITile.SLOPE_NE
							|| AITile.GetSlope(index) == AITile.SLOPE_SE
							|| AITile.GetSlope(index) == AITile.SLOPE_NW)){
								value += cost.slope;
							}

							vindex = vector.GetTileIndex(length);
							if(!(AITile.GetSlope(vindex) == AITile.SLOPE_SW
							|| AITile.GetSlope(vindex) == AITile.SLOPE_NE
							|| AITile.GetSlope(vindex) == AITile.SLOPE_SE
							|| AITile.GetSlope(vindex) == AITile.SLOPE_NW)){
								value += cost.slope;
							}

							this.CheckValue(vector.GetTileIndex(length + 1), origin, value);
							break;
						}
					}
				}

				length++;
			}while(length < 15);
		}
	}
}

function RailAstarFinder::GetRailTrack(from, tile, to){
	return RailAstarFinder.GetRailTrackFromSides(MapTile.GetDirection(tile, from), MapTile.GetDirection(tile, to));
}

function RailAstarFinder::GetRailTrackFromSides(from, to){
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

function RailAstarFinder::IsConnected(from, to){
	if(RailAstarFinder.IsConnectedToSide(from,  MapTile.GetDirection(from, to)) && RailAstarFinder.IsConnectedToSide(to,  MapTile.GetDirection(to, from))) return true;
	return false;
}

function RailAstarFinder::IsConnectedToSide(tile, side){
	switch(side){
		case AITile.SLOPE_NW: return AIRail.GetRailTracks(tile) & (AIRail.RAILTRACK_NW_SE | AIRail.RAILTRACK_NW_NE | AIRail.RAILTRACK_NW_SW);
		case AITile.SLOPE_SW: return AIRail.GetRailTracks(tile) & (AIRail.RAILTRACK_NE_SW | AIRail.RAILTRACK_SW_SE | AIRail.RAILTRACK_NW_SW);
		case AITile.SLOPE_SE: return AIRail.GetRailTracks(tile) & (AIRail.RAILTRACK_NW_SE | AIRail.RAILTRACK_SW_SE | AIRail.RAILTRACK_NE_SE);
		case AITile.SLOPE_NE: return AIRail.GetRailTracks(tile) & (AIRail.RAILTRACK_NE_SW | AIRail.RAILTRACK_NW_NE | AIRail.RAILTRACK_NE_SE);
	}
	throw("Error");
}


function RailAstarFinder::HasSignal(index, towards){
	local vector = MapVector.Create(index, towards);
	if(AIRail.GetSignalType(index, vector.GetTileIndex(-1)) != AIRail.SIGNALTYPE_NONE) return true;
	if(AIRail.GetSignalType(index, vector.GetSideTileIndex(1)) != AIRail.SIGNALTYPE_NONE) return true;
	if(AIRail.GetSignalType(index, vector.GetSideTileIndex(-1)) != AIRail.SIGNALTYPE_NONE) return true;
	return false;
}