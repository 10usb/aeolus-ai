require("node.nut");
require("queue.nut");
require("track.nut");

class RailPathFinder {
	startpoints	= null;
	endpoints	= null;
	increment	= null;
	
	queue		= null;
	queued		= null;
	nodes		= null;
	maxdistance = null;
	center 		= null;
	
	path 		= null;
	
	signs		= null;
	
	constructor(startpoints, endpoints, increment){
		this.startpoints	= startpoints;
		this.endpoints 		= endpoints;
		this.increment 		= increment;
		this.signs = Signs();
	}
}

function RailPathFinder::Init(){
	this.queue			= RailPathQueue();
	this.nodes			= {};
	
	// Set-up max bounds
	local startpoint 	= MapTile.GetAverageIndex(this.startpoints);
	local endpoint	 	= MapTile.GetAverageIndex(this.endpoints);
	this.maxdistance	= AIMap.DistanceSquare(startpoint, endpoint) * 0.6;
	this.center			= MapTile.GetAverageIndex([startpoint, endpoint]);
	
	this.signs.Build(startpoint, "Start");
	this.signs.Build(endpoint, "End");
	this.signs.Build(this.center, "Center");
	
	// Add each start node to de nodes
	foreach(index, dummy in this.startpoints){
		if(!this.nodes.rawin(index)){
			local node = RailPathNode(index, null);
			node.speed = this.increment;
			this.nodes.rawset(index, node);
			this.queue.Add(node);
		}
	}
}
	
function RailPathFinder::Search(){
	AILog.Info("Searching...");
	
    //	while nodes in queue
	// 		pop node from queue
	//		for each neighbor of node not in nodes as nindex
	//			for each neighbor of nindex in nodes
	//				create new node
	//				check if new node can point towards
	//				create value and compare value
	//				if compare value is better then best or there is no best make best
	//			add best to new nodes
	//		for each new node in new nodes
	//			add to nodes and to queue
	while(this.Step());

	signs.Clean();
	AILog.Info("Picking");
	
	foreach(index, dummy in this.endpoints){
		if(this.nodes.rawin(index)){
			local node = this.nodes.rawget(index);
			this.endpoints.SetValue(index, node.time.tointeger());
		}
	}
	
	this.endpoints.Sort(AIList.SORT_BY_VALUE, true);
	this.endpoints.KeepAboveValue(0);
	
	this.path = [];
	foreach(tile, dummy in this.endpoints){
		if(this.nodes.rawin(tile)){
			local current = this.nodes.rawget(tile);
			while(current!=null){
				if(current.forerunner && current.forerunner.forerunner){
					this.signs.Build(current.index, "" + floor(current.speed * 100));
					
					local track = RailPathTrack(current.forerunner.index);
					track.from = current.forerunner.forerunner.index;
					track.to = current.index;
					this.path.insert(0, track);
				}
				current = current.forerunner;
			}
			break;
		}
	}
	
	this.nodes = null;
	signs.Clean();	
	
	return this.path;
}

function RailPathFinder::Step(){
	if(this.queue.Count() <= 0) return false;
	
	local node = this.queue.Poll();
	
	local nnodes = [];
	foreach(index in this.FindNewNeighborIndexes(node)){
		local best = null;
		foreach(forerunner in this.FindNeighbors(AIMap.GetTileX(index), AIMap.GetTileY(index))){
			local nnode = RailPathNode(index, forerunner);
			if(!nnode.CanBuild()) continue;
			nnode.Calculate(this.increment);
			
			if(best == null){
				best = nnode;
			}else if(best.extra > nnode.extra){
				best = nnode;
			}
		}
		if(best!=null) nnodes.push(best);
	}
	
	foreach(nnode in nnodes){
		this.nodes.rawset(nnode.index, nnode);
		this.queue.Add(nnode);
		//if((this.nodes.len() % 150)==0) this.signs.Build(nnode.index, "" + floor(nnode.extra));
		
		//if((this.nodes.len() % 1)==0) this.queue.Print();
	}
	
	return true;
}

/**
 * Returns surrounding indexes except in the directen de given note is pointing
 */
function RailPathFinder::FindNewNeighborIndexes(node){
	local list	= [];
	local index	= null;
	
	index = AIMap.GetTileIndex(node.x - 1, node.y);// SLOPE_NE
	if(!this.nodes.rawin(index) && AITile.IsBuildable(index) && AIMap.DistanceSquare(index, this.center) < this.maxdistance) list.push(index);
	
	index = AIMap.GetTileIndex(node.x, node.y - 1); // SLOPE_NW
	if(!this.nodes.rawin(index) && AITile.IsBuildable(index) && AIMap.DistanceSquare(index, this.center) < this.maxdistance) list.push(index);
	
	index = AIMap.GetTileIndex(node.x + 1, node.y); // SLOPE_SW
	if(!this.nodes.rawin(index) && AITile.IsBuildable(index) && AIMap.DistanceSquare(index, this.center) < this.maxdistance) list.push(index);
	
	index = AIMap.GetTileIndex(node.x, node.y + 1); // SLOPE_SE
	if(!this.nodes.rawin(index) && AITile.IsBuildable(index) && AIMap.DistanceSquare(index, this.center) < this.maxdistance) list.push(index);
	
	return list;
}

/**
 * Returns surrounding nodes
 */
function RailPathFinder::FindNeighbors(x, y){
	local list	= [];
	local index	= null;
	
	index = AIMap.GetTileIndex(x - 1, y);// SLOPE_NE
	if(this.nodes.rawin(index)) list.push(this.nodes.rawget(index));
	
	index = AIMap.GetTileIndex(x, y - 1); // SLOPE_NW
	if(this.nodes.rawin(index)) list.push(this.nodes.rawget(index));
	
	index = AIMap.GetTileIndex(x + 1, y); // SLOPE_SW
	if(this.nodes.rawin(index)) list.push(this.nodes.rawget(index));
	
	index = AIMap.GetTileIndex(x, y + 1); // SLOPE_SE
	if(this.nodes.rawin(index)) list.push(this.nodes.rawget(index));
	
	return list;
}


function RailPathFinder::GetRailTrack(from, to){
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