class RailScanNode {
	index   = null;
    to      = null;
	towards = null;
	value   = 0;
	total   = 0;
}

function RailScanNode::GetBuildableCount(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.IsBuildable);
    list.KeepValue(1);
    return list.Count();
}

function RailScanNode::GetWaterTileCount(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.IsWaterTile);
    list.KeepValue(1);
    return list.Count();
}

function RailScanNode::GetCoastTileCount(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.IsCoastTile);
    list.KeepValue(1);
    return list.Count();
}

function RailScanNode::GetFarmTileCount(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.IsFarmTile);
    list.KeepValue(1);
    return list.Count();
}

function RailScanNode::GetFlatTileCount(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(RailScanNode.IsFlat);
    list.KeepValue(1);
    return list.Count();
}

function RailScanNode::GetAvgHeight(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.GetMinHeight);
    local min = Lists.GetSum(list);
    list.Valuate(AITile.GetMaxHeight);
    return (min + Lists.GetSum(list)) / (list.Count() * 2);
}

function RailScanNode::GetDistance(destination){
    return (sqrt(AIMap.DistanceSquare(index, destination)) + sqrt(AIMap.DistanceSquare(index, destination))).tointeger() / 2;
}

function RailScanNode::Sign(text){
    /** /
    AISign.BuildSign(index, text);
    AISign.BuildSign(to, text);
    AISign.BuildSign(AIMap.GetTileIndex(AIMap.GetTileX(index), AIMap.GetTileY(to)), text);
    AISign.BuildSign(AIMap.GetTileIndex(AIMap.GetTileX(to), AIMap.GetTileY(index)), text);
    /**/
    local list = AITileList();
    list.AddRectangle(index, to);
    list.RemoveRectangle(AIMap.GetTileIndex(
            AIMap.GetTileX(index) + 1,
            AIMap.GetTileY(index) + 1
        ), AIMap.GetTileIndex(
            AIMap.GetTileX(to) - 1,
            AIMap.GetTileY(to) - 1
        ));
    foreach(tile, dummy in list){
        AISign.BuildSign(tile, text);
    }
    /**/
}

function RailScanNode::IsFlat(index){
    return AITile.GetMinHeight(index) == AITile.GetMaxHeight(index) ? 1 : 0;
}