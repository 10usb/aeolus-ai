class RailScanFinder {
    resolution  = 6;

    startpoints = null;
    endpoints   = null;

    nodes       = null;
    queue       = null;
    done        = 0;

	constructor(resolution){
        this.resolution = resolution;
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
    startpoints = List.Flip(startpoints.Valuate(RailScanFinder.GetTile, resolution));
    endpoints   = List.Flip(endpoints.Valuate(RailScanFinder.GetTile, resolution));

    foreach(index in startpoints){
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
    endpoints.Valuate(AIMap.DistanceManhattan, node.index);
    endpoints.Sort(AIList.SORT_BY_VALUE, true);
    value+= endpoints.GetValue(endpoints.Begin()) * resolution * resolution;
    queue.AddItem(node.index, value);
}

function RailScanFinder::Get(index){
    if(nodes.rawin(index)) return nodes.rawget(index);

    local node = RailScanNode();
    node.index  = index;
    node.to     = AIMap.GetTileIndex(
            AIMap.GetTileX(index) + resolution,
            AIMap.GetTileY(index) + resolution
        );
    node.total = node.value = Calculate(node);
    return node;
}

function RailScanFinder::Calculate(node){
    local tiles = resolution * resolution;
    local cost = tiles;
    cost+= tiles - node.GetBuildableCount();
    cost+= node.GetWaterTileCount() * 10;
    cost+= node.GetCoastTileCount() * 2;
    cost+= node.GetFarmTileCount();
    cost+= tiles - node.GetFlatTileCount();
    return cost;
}

function RailScanFinder::Step(){
    if(done >= endpoints.Count()) return false;
	if(queue.Count() <= 0) return false;
	local node = Dequeue();

    if(node.towards){
        local vector = MapVector.Create(node.index, node.towards);
        Check(vector.GetTileIndex(-resolution), node);
        Check(vector.GetSideTileIndex(resolution), node);
        Check(vector.GetSideTileIndex(-resolution), node);
    }else{
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index) + resolution, AIMap.GetTileX(node.index)), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index) - resolution, AIMap.GetTileX(node.index)), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index), AIMap.GetTileX(node.index) + resolution), node);
        Check(AIMap.GetTileIndex(AIMap.GetTileX(node.index), AIMap.GetTileX(node.index) - resolution), node);
    }

    return true;
}

function RailScanFinder::Check(index, towards){
    local node = Get(index);
    local extra = Math.abs(node.GetAvgHeight() + towards.GetAvgHeight()) * (resolution * resolution);
    local total = towards.total + node.value;
    if(total < node.total){
        node.total = total;
        node.towards = towards.index;

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