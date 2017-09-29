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

function RailScanNode::IsFlat(index){
    return AITile.GetMinHeight(index) == AITile.GetMaxHeight(index) ? 1 : 0;
}

function RailScanNode::GetAvgHeight(){
    local list = AITileList();
    list.AddRectangle(index, to);
    list.Valuate(AITile.GetMinHeight);
    local min = List.GetSum(list);
    list.Valuate(AITile.GetMaxHeight);
    return (min + List.GetSum(list)) / (list.Count() * 2);
}