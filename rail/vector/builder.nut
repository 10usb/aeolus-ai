class RailVectorBuilder {
}

function RailVectorBuilder::Level(vector, index, origin){
}

function RailVectorBuilder::Build(vector, index, origin){
    if(vector.bridge){
        local to = vector.GetTileIndex(index, origin, vector.length - 1);
        local bridges = AIBridgeList_Length(vector.length);
        AIBridge.BuildBridge(Vehicle.VT_RAIL, bridges.Begin(), index, to);
    }else{
        local from = Tile.GetSlopeTileIndex(index, origin);
        local to = vector.GetTileIndex(index, origin);
        Rail.BuildRail(from, index, to);
    }
}