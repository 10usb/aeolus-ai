require("node.nut");
require("queue.nut");

class RailPathFinder {
    signs		= null;
	queue		= null;
	nodes		= null;
    startpoints = null;
    endpoints   = null;
    distance    = null;
    success     = null;
    radius      = null;

	constructor(){
		this.signs       = Signs();
        this.queue       = RailPathQueue();
        this.nodes       = {};
        this.startpoints = {};
        this.endpoints   = AIList();
	}
}

function RailPathFinder::AddStartPoint(index, towards, value){
    this.startpoints.rawset(index, {
        towards = towards,
        value = value
    });

    this.signs.Build(index, "start: " + value);
    this.signs.Build(towards, "from: " + value);
}

function RailPathFinder::AddEndPoint(index, value){
    this.endpoints.AddItem(index, value);
    this.signs.Build(index, "end: " + value);
}

function RailPathFinder::Init(){
    // When no end point's then nothing todo
    if(this.endpoints.Count() <=0) return;

    this.distance = AIList();
    this.distance.AddList(this.endpoints);
    
    this.success = AIList();
    this.success.AddList(this.endpoints);
    this.success.Valuate(List.SetValue, 0);

    this.radius = null;

    foreach(index, point in this.startpoints){
        local node = RailPathNode(index, null, point.value);
        node.towards = Tile.GetDirection(index, point.towards);
        node.fixed = true;
        this.nodes.rawset(index, node);
        this.queue.Add(node);
        
        local radius = this.GetDistance(index); 
        if(this.radius == null || radius < this.radius){
            this.radius = radius;
        }
    }

    this.radius = (this.radius * 1.2).tointeger();
}

function RailPathFinder::Step(){
	if(this.queue.Count() <= 0) return false;
	
    // Poll queue
	local node = this.queue.Poll();
    local tilted = Tile.GetSlope(node.index) != Tile.SLOPE_FLAT;
    
    // Test candidates
    foreach(index, slope in node.GetCandidates()){
        // Is index buildable
        if(!Tile.IsBuildable(index))
            continue;
        
        // Get cost value
        local cost = 10 + node.value;
        
        if(node.towards != 0){
            if(tilted && Tile.GetComplementSlope(slope) == node.towards) cost+= 200;
        }

        // If it's an endpoint
        if(endpoints.HasItem(index)){   
            if(this.MarkEndpoint(index, node, cost)) return false;
        }else{
            // Compare cost to an already existing node
            // If less then replace and add to the queue
            this.Enqueue(index, node, cost);
        }
    }

    return true;
}

function RailPathFinder::Enqueue(index, forerunner, cost){
    if(this.nodes.rawin(index)){
        local current = this.nodes.rawget(index);

        if(!current.fixed && cost < current.value){
            local distance = this.GetDistance(index);
            if(distance > this.radius) return;

            local node = RailPathNode(index, forerunner, cost);
            node.extra = (distance * 8).tointeger();

            this.nodes.rawset(node.index, node);
            this.queue.Add(node);
            // this.signs.Build(node.index, "" + node.value);
        }
    }else{
        local distance = this.GetDistance(index);
        if(distance > this.radius) return;

        local node = RailPathNode(index, forerunner, cost);
        node.extra = (distance * 8).tointeger();

        this.nodes.rawset(node.index, node);
        this.queue.Add(node);
        // this.signs.Build(node.index, "" + node.value);
    }
}

function RailPathFinder::GetDistance(index){
    this.distance.Valuate(Tile.GetDistanceSquareToTile, index);
    this.distance.Sort(AIList.SORT_BY_VALUE, false);
    return sqrt(this.distance.GetValue(this.distance.Begin()));
}

function RailPathFinder::MarkEndpoint(index, forerunner, cost){
    if(this.nodes.rawin(index)){
        local current = this.nodes.rawget(index);

        if(cost < current.value){
            local node = RailPathNode(index, forerunner, cost);
            this.nodes.rawset(index, node);
            this.success.SetValue(index, cost);
        }
    }else{
        local node = RailPathNode(index, forerunner, cost);
        this.nodes.rawset(index, node);
        this.success.SetValue(index, cost);
    }

    return true;
}

function RailPathFinder::GetPath(){
    local best = AIList();
    best.AddList(this.success);
    best.KeepAboveValue(0);

    if(best.Count() <= 0) return [];

    best.Sort(AIList.SORT_BY_VALUE, true);
    local current = this.nodes.rawget(best.Begin());

    local path = [];
    while(current != null){
        this.signs.Build(current.index, "" + current.value);

        current = current.forerunner;
    }

    path.reverse();
    return path;
}