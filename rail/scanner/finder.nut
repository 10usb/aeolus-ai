class RailScannerFinder {
    max         = 10000;
    keep        = 9000;
    reseed      = 0;

    startpoints = null;
    endpoints   = null;

    nodes       = null;
    queue       = null;
    backlog     = null;
    done        = 0;
    countdown   = 0;

	constructor(max = 10000, keep = 9000, reseed = 0){
        this.max    = max;
        this.keep   = keep;
        this.reseed = reseed;
        startpoints = AIList();
        endpoints   = AIList();

        nodes = {};
        queue = AIList();
        queue.Sort(AIList.SORT_BY_VALUE, true);

        backlog = AIList();
        backlog.Sort(AIList.SORT_BY_VALUE, true);
    }
}

function RailScannerFinder::AddStartpoints(points){
    startpoints.AddList(points);
}

function RailScannerFinder::AddEndpoint(points){
    endpoints.AddList(points);
}

function RailScannerFinder::Init(){
    foreach(index, dummy in startpoints){
        Enqueue(Get(index));
    }
}

function RailScannerFinder::Dequeue(){
	local index = queue.Begin();
    queue.RemoveTop(1);
    return nodes.rawget(index);
}

function RailScannerFinder::Enqueue(node){
    endpoints.Valuate(AIMap.DistanceSquare, node.index);
    endpoints.Sort(AIList.SORT_BY_VALUE, true);
    local index = endpoints.Begin();
    
    local value = node.value + (sqrt(endpoints.GetValue(index)) * 10).tointeger();
    queue.AddItem(node.index, value);

    if(queue.Count() > max) {
        local selection = AIList();
        selection.AddList(queue);
        selection.Valuate(AIMap.DistanceSquare, index);
        selection.Sort(AIList.SORT_BY_VALUE, true);
        selection.KeepTop(keep);

        local unwanted = AIList();
        unwanted.AddList(queue);
        unwanted.RemoveList(selection);
        backlog.AddList(unwanted);

        queue.KeepList(selection);

        backlog.RemoveList(queue);

        local reseeded = AIList();
        reseeded.AddList(backlog);
        reseeded.Sort(AIList.SORT_BY_VALUE, true);
        reseeded.KeepTop(reseed);
        queue.AddList(reseeded);
        backlog.RemoveList(reseeded);
        queue.Sort(AIList.SORT_BY_VALUE, true);

        //AILog.Info("Clean-up (" + backlog.Count() + ")");
    }
}

function RailScannerFinder::Get(index){
    if(nodes.rawin(index)) return nodes.rawget(index);

    local node = RailScannerNode();
    node.index      = index;
    node.towards    = AIMap.TILE_INVALID;
    node.value      = 0;
    nodes.rawset(index, node);
    return node;
}

function RailScannerFinder::GetPath(){
    local best = null;
    foreach(index, dummy in endpoints){
        if(nodes.rawin(index)){
            local node = nodes.rawget(index);
            if(best == null){
                best = node;
            }else if(node.value < best.value){
                best = node;
            }
        }
    }
    if(best == null) return false;
    
    local current = best;
    while(true){
        current.Sign("" + current.value);

        if(!AIMap.IsValidTile(current.towards)) break;
        current = nodes.rawget(current.towards);
    }
}

function RailScannerFinder::Step(){
    if(done > 0){
        if(done >= endpoints.Count()) {
            AILog.Info("done"); return false;
        }
        if(++countdown > 300){
            AILog.Info("countdown"); return false;
        }
    }
    
	if(queue.Count() <= 0) {
        if(backlog.Count() <= 0) {
            AILog.Info("no queue"); return false;
        }
        local reseeded = AIList();
        reseeded.AddList(backlog);
        reseeded.KeepTop(keep);
        queue.AddList(reseeded);
        backlog.RemoveList(reseeded);
    }
	local node = Dequeue();

    if(AIMap.IsValidTile(node.towards)){
        local vector = MapVector.Create(node.index, node.towards).Normalize();
        Check(vector.GetTileIndex(-1), node);
        Check(vector.GetSideTileIndex(1), node);
        Check(vector.GetSideTileIndex(-1), node);
    }else{
        Check(Tile.GetTranslatedIndex(node.index, 1, 0), node);
        Check(Tile.GetTranslatedIndex(node.index, -1, 0), node);
        Check(Tile.GetTranslatedIndex(node.index, 0, 1), node);
        Check(Tile.GetTranslatedIndex(node.index, 0, -1), node);
    }

    return true;
}

function RailScannerFinder::Check(index, towards){
    if(!AIMap.IsValidTile(index)) return;

    if(!Tile.IsBuildable(index)){
        if(Tile.IsCrossable(index)){
            CheckBridge(index, towards);
        }
        return;
    }

    local node  = Get(index);
    if(node.value > 0 && node.value < towards.value){
        Check(towards.index, node);
        return;
    }
    local cost  = towards.value + 10;
    cost += (Tile.GetMaxHeight(index) - Tile.GetMinHeight(index)) * 50;


    if(node.value == 0 || cost < node.value){
        node.value      = cost;
        node.towards    = towards.index;
        // node.Sign("" + node.value);

        if(endpoints.HasItem(node.index)){
            done++;
            //AILog.Info("done (" + done + " / " + endpoints.Count() + ")");
        }else{
            Enqueue(node);
        }
    }
}

function RailScannerFinder::CheckBridge(index, towards){
    local vector = MapVector.Create(index, towards.index).Normalize();
    
    local sindex = vector.GetTileIndex(2);
    if(!nodes.rawin(sindex)) return;
    //AISign.BuildSign(sindex, "Bridge start");

    local length = -1;
    local vindex = 0;
    while(length > -12 && !Tile.IsBuildable(vindex = vector.GetTileIndex(length)) && !Tile.IsBuildable(vector.GetTileIndex(length - 1))){
        length--;
    }
    if(length <= -12) return;


    //AISign.BuildSign(vindex, "Bridge end");
    local node  = Get(vindex);
    local cost  = towards.value + 100;
    cost += (Tile.GetMaxHeight(vindex) - Tile.GetMinHeight(vindex)) * 50;

    if(node.value == 0 || cost < node.value){
        node.value      = cost;
        node.towards    = towards.index;
        // node.Sign("" + node.value);

        if(endpoints.HasItem(node.index)){
            done++;
            //AILog.Info("done (" + done + " / " + endpoints.Count() + ")");
        }else{
            Enqueue(node);
        }
    }
}