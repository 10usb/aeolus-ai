require("node.nut");

class RoadPathFinder {
    signs		= null;
	queue		= null;
	nodes		= null;
    startpoints = null;
    endpoints   = null;
    distance    = null;
    success     = null;
    radius      = null;
    exclusions  = null;
    virtual     = null;
    railType    = null;
    debug       = false;
    next        = null;
    explore     = true;
    entries     = null;

	constructor(){
		this.signs       = Signs();
        this.queue       = AIPriorityQueue();
        this.nodes       = {};
        this.startpoints = {};
        this.endpoints   = AIList();
        this.exclusions  = AIList();
        this.virtual     = AIList();
	}
}

function RoadPathFinder::AddStartPoint(index, towards, value){
    // Make sure the start tile is buildable
    if(!Tile.IsBuildable(index) && !Road.IsRoadTile(index)) return;
    // TODO check if the towards side is level

    local meta = {
        towards = towards,
        value = value,
        exclusions = AIList()
    };
    this.startpoints.rawset(index, meta);

    // The tile it's poining to can used
    meta.exclusions.AddItem(towards, 0);

    if(debug){
        this.signs.Build(index, "start: " + value);
        this.signs.Build(towards, "from: " + value);
    }
}

function RoadPathFinder::AddEndPoint(index, value){
    this.endpoints.AddItem(index, value);
    if(debug) this.signs.Build(index, "end: " + value);
}

function RoadPathFinder::AddExclusion(index, start){
    if(this.startpoints.rawin(start)){
        this.startpoints.rawget(start).exclusions.AddItem(index, 0);
        if(debug) this.signs.Build(index, "EXCLUDED");
    }
}

function RoadPathFinder::AddVirtual(tiles){
    this.virtual.AddList(tiles);
}

function RoadPathFinder::Init(){
    // When no end point's then nothing todo
    if(this.endpoints.Count() <=0) return;

    this.distance = AIList();
    this.distance.AddList(this.endpoints);
    
    this.success = AIList();
    this.success.AddList(this.endpoints);
    this.success.Valuate(Lists.SetValue, 0);

    this.radius = null;

    
    this.explore = true;
    this.entries = AIList();

    foreach(index, point in this.startpoints){
        local node = RoadPathNode(index, null, point.value);
        node.towards = Tile.GetDirection(index, point.towards);
        node.start = point;
        this.nodes.rawset(index, node);
        this.queue.Insert(node, node.value + node.extra);
        
        local radius = this.GetDistance(index); 
        if(this.radius == null || radius < this.radius){
            this.radius = radius;
        }

        this.entries.AddItem(index, 0);
    }

    this.radius = (this.radius * 1.2).tointeger();

    // We need to set the current rail type otherwise 
    // we can't test if a bridge can be build
    local types = AIRailTypeList();
    types.Valuate(Rail.IsRailTypeAvailable);
    types.KeepValue(1);
    this.railType = types.Begin();

    this.next = null;
}

function RoadPathFinder::BeginStep(){
    Rail.SetCurrentRailType(this.railType);
}

function RoadPathFinder::Step(){
	if(this.queue.Count() <= 0) return false;
    
    // Poll queue
	local node = this.next;
    this.next = null;
    if(node == null)
        node = this.queue.Pop();

    local slope   = Tile.GetSlope(node.index);
    local tilted  = slope != Tile.SLOPE_FLAT;
    // If the current tile doesn't go up/down from it's origin it would create a ramp
    local ramp    = Tile.IsSlopeRamp(slope);
    local hasRoad = Road.HasRoadType(node.index, Road.ROADTYPE_ROAD);
    
    if(this.explore && this.GetDistance2(node.index) > 10){
        this.explore = false;
    }
    
    // Test candidates
    foreach(candidate in node.GetCandidates()){
        local index = candidate.index;
        local direction = candidate.direction;

        // When the tile is excluded, do nothing with it
        if(this.exclusions.HasItem(index) || node.start.exclusions.HasItem(index))
            continue;

        // When the tile is not buildable it might still be crossable
        if(!CanBuild(node, tilted, index, direction))
            continue;
        
        // We need to make this check to know if a bridge could be build
        if(this.nodes.rawin(index)){
            local dx = AIMap.GetTileX(index) - node.x;
            local dy = AIMap.GetTileY(index) - node.y;

            local jump = AIMap.GetTileIndex(node.x + dx + dx, node.y + dy + dy);
            if(Tile.IsCrossable(jump)){
                this.CheckBridge(node, index);
            }
        }

        // Get penalty value
        local penalty = Road.IsRoadTile(index) ? -5 : 0;

        if(this.virtual.HasItem(index))
            penalty-= 10;
        
        if(tilted){
            penalty+= 30;

            if(node.forerunner == null || !Road.CanBuildConnectedRoadPartsHere(node.index, node.forerunner.index, index))
                continue;

            // While the game setting might allow ramps, I don't like it.
            if(!Road.AreRoadTilesConnected(node.index, index)){
                if(ramp)
                    penalty+= 30;

                if(Tile.IsSlopeRamp(Tile.GetSlope(index)))
                    penalty+= 30;
            }
        }

        local complement = !this.explore && Tile.GetComplementSlope(direction) == node.towards;

        // When going off-road
        if(hasRoad && !Road.HasRoadType(index, Road.ROADTYPE_ROAD)){
            complement = false;
            penalty+= 5;
        }

        // When going not straight
        if(!complement)
            penalty+= 5;

        // To avoid crossing farmland
        if(Tile.IsFarmTile(index))
            penalty+= 30;

        // If it's an endpoint mark it
        if(endpoints.HasItem(index)){   
            if(this.MarkEndpoint(index, node, penalty)) return false;
        }else{
            // Compare cost to an already existing node
            // If less then replace and add to the queue
            this.Enqueue(index, node, 10, penalty, complement, MapVector.Create(node.index, index));
        }
    }

    return true;
}

function RoadPathFinder::CanBuild(forerunner, tilted, index, slope){
    // If the tile is empty then ok
    if(Tile.IsBuildable(index)) return true;
    
    // When it's not a road tile we can build on it
    if(!Road.HasRoadType(index, Road.ROADTYPE_ROAD))
        return false;

    if(AIBridge.IsBridgeTile(index)){
        // Get the end + 1
        local end = AIBridge.GetOtherBridgeEnd(index);
        local direction = Tile.GetDirection(index, end);

        if(direction == slope){
            local vector = MapVector.Create(index, end).Normalize();
            local length = Tile.GetDistanceManhattanToTile(index, end);
            end = vector.GetTileIndex(length + 1);

            local cost = length * 5;
            local node = this.Enqueue(end, forerunner, cost, 0, true, MapVector.Create(forerunner.index, end));
            if(node != null){
                node.bridge = true;
            }
        }

        return false;
    }

    if(!Road.IsRoadTile(index)) return false;
    return !Rail.IsRailTile(index);
}

function RoadPathFinder::CheckBridge(forerunner, to){
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
            local penalty = 200 + length * 20;
            local node = this.Enqueue(index, forerunner, 0, penalty, false, vector);
            if(node != null){
                node.bridge = true;
            }
            return true;
        }

        break;
    }
    return false;
}

function RoadPathFinder::Enqueue(index, forerunner, cost, penalty, complement, vector){
    cost = forerunner.value + cost + penalty;

    if(this.nodes.rawin(index)){
        local current = this.nodes.rawget(index);

        // If the node is pointing to a invalid forerunner because it was changed
        local invalid = current.forerunner != null && current.start != current.forerunner.start;

        if(invalid || cost < current.value){
            local distance = this.GetDistance(vector.GetTileIndex(10));
            if(distance > this.radius) return;

            current.forerunner = forerunner;
            current.value = cost;
            current.towards = Tile.GetDirection(index, forerunner.index);
            current.extra = (distance * 12).tointeger();
            current.bridge = false;
            current.start = forerunner.start;

            this.queue.Insert(current, current.value + current.extra);
            if(this.debug) this.signs.Build(current.index, "" + current.value);

            return current;
        }
        return null;
    }else{
        local distance = this.GetDistance(index);
        if(distance > this.radius) return;


        local node = RoadPathNode(index, forerunner, cost);
        node.extra = (distance * 12).tointeger();
        node.start = forerunner.start;

        this.nodes.rawset(node.index, node);
        if(complement && penalty <= 0){
            if(node.extra < forerunner.extra){
                if(this.next==null || !this.next.bridge)
                    this.next = node;
            }else{
                this.queue.Insert(node, node.value + node.extra);
            }
        }else{
            this.queue.Insert(node, node.value + node.extra);
        }
        
        if(this.debug) this.signs.Build(node.index, "" + node.value);
        return node;
    }
}

function RoadPathFinder::GetDistance(index){
    this.distance.Valuate(Tile.GetDistanceManhattanToTile, index);
    this.distance.Sort(AIList.SORT_BY_VALUE, false);
    return this.distance.GetValue(this.distance.Begin());
}

function RoadPathFinder::GetDistance2(index){
    this.entries.Valuate(Tile.GetDistanceManhattanToTile, index);
    this.entries.Sort(AIList.SORT_BY_VALUE, true);
    return this.entries.GetValue(this.entries.Begin());
}

function RoadPathFinder::MarkEndpoint(index, forerunner, cost){
    cost = forerunner.value + 10 + cost;
    if(this.nodes.rawin(index)){
        local current = this.nodes.rawget(index);

        if(cost < current.value){
            local node = RoadPathNode(index, forerunner, cost);
            this.nodes.rawset(index, node);
            this.success.SetValue(index, cost);
        }
    }else{
        local node = RoadPathNode(index, forerunner, cost);
        this.nodes.rawset(index, node);
        this.success.SetValue(index, cost);
    }

    return true;
}

function RoadPathFinder::GetBest(){
    this.signs.Clean();
    local best = AIList();
    best.AddList(this.success);
    best.KeepAboveValue(0);

    if(best.Count() <= 0) return -1;

    best.Sort(AIList.SORT_BY_VALUE, true);
    return best.GetValue(best.Begin());
}

function RoadPathFinder::GetPath(){
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