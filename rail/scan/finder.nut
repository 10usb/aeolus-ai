class RailScanFinder {
    resolution  = 6;
    max         = 40;
    keep        = 20;

    startpoints = null;
    endpoints   = null;

    nodes       = null;
    queue       = null;
    done        = 0;

	constructor(resolution, max, keep){
        this.resolution = resolution;
        this.max = max;
        this.keep = keep;
        startpoints = AIList();
        endpoints = AIList();

        nodes = {};
        queue = AIList();
        queue.Sort(AIList.SORT_BY_VALUE, true);
    }
}

function RailScanFinder::AddStartpoints(points){
    startpoints.AddList(points);
}

function RailScanFinder::AddEndpoint(points){
    endpoints.AddList(points);
}

function RailScanFinder::Init(){
    startpoints.Valuate(RailScanFinder.GetTile, resolution);
    startpoints = List.Flip(startpoints);

    endpoints.Valuate(RailScanFinder.GetTile, resolution);
    endpoints   = List.Flip(endpoints);

    foreach(index, dummy in startpoints){
        Enqueue(Get(index));
    }
}

function RailScanFinder::Dequeue(){
	local index = queue.Begin();
    queue.RemoveTop(1);
    return nodes.rawget(index);
}

function RailScanFinder::Enqueue(node){
    local value = node.total;
    endpoints.Valuate(AIMap.DistanceSquare, node.index);
    endpoints.Sort(AIList.SORT_BY_VALUE, true);
    local index = endpoints.Begin();
    value+= sqrt(endpoints.GetValue(index)).tointeger() * resolution * resolution;
    queue.AddItem(node.index, value);

    if(queue.Count() > max) {
        //AILog.Info("Clean-up");
        local selection = AIList();
        selection.AddList(queue);
        selection.Valuate(AIMap.DistanceSquare, index);
        selection.Sort(AIList.SORT_BY_VALUE, true);
        selection.KeepTop(keep);
        queue.KeepList(selection);
    }
}

function RailScanFinder::Get(index){
    if(nodes.rawin(index)) return nodes.rawget(index);

    local node = RailScanNode();
    node.index  = index;
    node.to     = AIMap.GetTileIndex(
            Math.min(AIMap.GetTileX(index) + resolution - 1, AIMap.GetMapSizeX()),
            Math.min(AIMap.GetTileY(index) + resolution - 1, AIMap.GetMapSizeY())
        );
    node.total = 0;
    node.towards = AIMap.TILE_INVALID;
    node.value = Calculate(node);
    nodes.rawset(index, node);
    return node;
}

function RailScanFinder::GetPath(){
    local best = null;
    foreach(index, dummy in endpoints){
        if(nodes.rawin(index)){
            local node = nodes.rawget(index);
            if(best == null){
                best = node;
            }else if(node.total < best.total){
                best = node;
            }
        }
    }
    if(best == null) return false;
    
    local current = best;
    while(true){
        current.Sign("" + current.total);

        if(!AIMap.IsValidTile(current.towards)) break;
        current = nodes.rawget(current.towards);
    }
}

function RailScanFinder::Calculate(node){
    local tiles = resolution * resolution;
    local cost = tiles;
    cost+= (tiles - node.GetBuildableCount()) * 15;
    cost+= node.GetWaterTileCount() * 20;
    cost+= node.GetCoastTileCount() * 10;
    cost+= node.GetFarmTileCount() / 2;
    cost+= (tiles - node.GetFlatTileCount()) * 5;
    return cost;
}

function RailScanFinder::Step(){
    if(done >= endpoints.Count()) { AILog.Info("done"); return false;}
	if(queue.Count() <= 0) { AILog.Info("no queue"); return false;}
	local node = Dequeue();

    if(AIMap.IsValidTile(node.towards)){
        local vector = MapVector.Create(node.index, node.towards);
        Check(vector.GetTileIndex(-1), node);
        Check(vector.GetSideTileIndex(1), node);
        Check(vector.GetSideTileIndex(-1), node);
    }else{
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index) + resolution, AIMap.GetTileY(node.index)), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index) - resolution, AIMap.GetTileY(node.index)), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index), AIMap.GetTileY(node.index) + resolution), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index), AIMap.GetTileY(node.index) - resolution), node);
    }

    return true;
}

function RailScanFinder::Check(index, towards){
    if(!AIMap.IsValidTile(index)) return;
    local node = Get(index);
    local extra = (Math.abs(node.GetAvgHeight() + towards.GetAvgHeight()) * (resolution * resolution)) * 2;
    local total = towards.total + extra + node.value;

    if(node.total == 0 || total < node.total){
        node.total = total;
        node.towards = towards.index;
        //node.Sign("" + node.total);
        if(endpoints.HasItem(node.index)){
            done++;
        }else{
            Enqueue(node);
        }
    }
}

function RailScanFinder::GetTile(index, resolution){
    return AIMap.GetTileIndex(
            AIMap.GetTileX(index) / resolution * resolution,
            AIMap.GetTileY(index) / resolution * resolution
        );
}