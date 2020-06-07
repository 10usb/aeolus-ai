class RailVectorBuilder {
}

function RailVectorBuilder::Level(vector, index, origin){
}

function RailVectorBuilder::BuildRail(vector, index, origin){
    local from = Tile.GetSlopeTileIndex(index, origin);
    local to = vector.GetTileIndex(index, origin);
    Rail.BuildRail(from, index, to);
}

function RailVectorBuilder::BuildBridge(vector, index, origin){
    local to = vector.GetTileIndex(index, origin);
    local bridges = AIBridgeList_Length(vector.length);
    AIBridge.BuildBridge(Vehicle.VT_RAIL, bridges.Begin(), index, to);
}