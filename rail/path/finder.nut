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
    exclusions  = null;
    railType    = null;
    debug       = false;

	constructor(){
		this.signs       = Signs();
        this.queue       = RailPathQueue();
        this.nodes       = {};
        this.startpoints = {};
        this.endpoints   = AIList();
        this.exclusions  = AIList();
	}
}

function RailPathFinder::AddStartPoint(index, towards, value){
    this.startpoints.rawset(index, {
        towards = towards,
        value = value
    });
    this.exclusions.AddItem(towards, 0);

    // this.signs.Build(index, "start: " + value);
    // this.signs.Build(towards, "from: " + value);
}

function RailPathFinder::AddEndPoint(index, value){
    this.endpoints.AddItem(index, value);
    // this.signs.Build(index, "end: " + value);
}

function RailPathFinder::AddExclusion(index){
    this.exclusions.AddItem(index, 0);
    // this.signs.Build(index, "EXCLUDED");
}

function RailPathFinder::Init(){
    // When no end point's then nothing todo
    if(this.endpoints.Count() <=0) return;

    this.distance = AIList();
    this.distance.AddList(this.endpoints);
    
    this.success = AIList();
    this.success.AddList(this.endpoints);
    this.success.Valuate(Lists.SetValue, 0);

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

    // We need to set the current rail type otherwise 
    // we can't test if a bridge can be build
    local types = AIRailTypeList();
    types.Valuate(Rail.IsRailTypeAvailable);
    types.KeepValue(1);
    this.railType = types.Begin();
}

function RailPathFinder::BeginStep(){
    Rail.SetCurrentRailType(this.railType);
}

function RailPathFinder::Step(){
	if(this.queue.Count() <= 0) return false;
	
    // Poll queue
	local node = this.queue.Poll();
    local tilted = Tile.GetSlope(node.index) != Tile.SLOPE_FLAT;
    
    // Test candidates
    foreach(index, slope in node.GetCandidates()){
        // When the tile it excluded do nothing with it
        if(this.exclusions.HasItem(index))
            continue;

        // When the tile is not buildable it might still be crossable
        if(!Tile.IsBuildable(index)){
            if(node.forerunner != null && Tile.GetComplementSlope(slope) == node.towards && Tile.IsCrossable(index)){
                this.CheckBridge(node.forerunner, node.index);
            }
            continue;
        }

        // We need to make this check to know it a bridge could ne build
        if(this.nodes.rawin(index)){
            local x = AIMap.GetTileX(index) - node.x;
            local y = AIMap.GetTileY(index) - node.y;

            local jump = AIMap.GetTileIndex(node.x + x + x, node.y + y + y);
            if(Tile.IsCrossable(jump)){
                this.CheckBridge(node, index);
            }
        }
        
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

function RailPathFinder::CheckBridge(forerunner, to){
    // this.signs.Build(forerunner.index, "NODE");
    // this.signs.Build(to, "RAMP");

    local vector = MapVector.Create(forerunner.index, to);

    for(local length = 3; length <= 8; length++){
        local ramp = vector.GetTileIndex(length);
        if(!Tile.IsBuildable(ramp)){
            if(Tile.IsCrossable(ramp))
                continue;
            break;
        }
        
        // The ramps need may only differ 1, but a tile further ther might be an ok place
        if(abs(Tile.GetMaxHeight(ramp) - Tile.GetMaxHeight(to)) > 1){
            continue;
        }

        // The tile after the ramp
        local index = vector.GetTileIndex(length + 1);
        if(!Tile.IsBuildable(index)){
            if(Tile.IsCrossable(index)){
                length++;
                continue;
            }
            break;
        }

        local bridges = AIBridgeList_Length(length);
        local valid = false;
        if(bridges.Count() > 0){
            local mode = AITestMode();
            valid = AIBridge.BuildBridge(Vehicle.VT_RAIL, bridges.Begin(), to, ramp);
            mode = null;
        }

        if(valid){
            // this.signs.Build(ramp, "VALID");
            local cost = forerunner.value + 300 + length * 20;
            local node = this.Enqueue(index, forerunner, cost);
            if(node != null){
                node.bridge = true;
            }
        }

        break;
    }
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
            if(this.debug) this.signs.Build(node.index, "" + node.value);

            return node;
        }
        return null;
    }else{
        local distance = this.GetDistance(index);
        if(distance > this.radius) return;

        local node = RailPathNode(index, forerunner, cost);
        node.extra = (distance * 8).tointeger();

        this.nodes.rawset(node.index, node);
        this.queue.Add(node);
        if(this.debug) this.signs.Build(node.index, "" + node.value);
        return node;
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

function RailPathFinder::GetBest(){
    this.signs.Clean();
    local best = AIList();
    best.AddList(this.success);
    best.KeepAboveValue(0);

    if(best.Count() <= 0) return [];

    best.Sort(AIList.SORT_BY_VALUE, true);
    return best.GetValue(best.Begin());
}

function RailPathFinder::GetPath(){
    this.signs.Clean();
    local best = AIList();
    best.AddList(this.success);
    best.KeepAboveValue(0);

    if(best.Count() <= 0) return [];

    best.Sort(AIList.SORT_BY_VALUE, true);
    local current = this.nodes.rawget(best.Begin());

    local path = [];
    for(;;){
        path.push(current.index);
        if(current.forerunner == null) break;

        // Add 2 indexed for the ramps
        if(current.bridge){
            local distance = Tile.GetDistanceManhattanToTile(current.index, current.forerunner.index);
            local vector = MapVector.Create(current.index, current.forerunner.index).Normalize();
            path.push(vector.GetTileIndex(1));
            path.push(vector.GetTileIndex(distance - 1));
        }

        current = current.forerunner;
    }

    // Add the one preceding the path to the begining of it
    path.push(this.startpoints.rawget(current.index).towards);

    path.reverse();
    return path;
}