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

function RailVectorBuilder::BuildChain(root){
    Log.Info("Building");

    local signs = Signs();

    local types = AIRailTypeList();
    types.Valuate(Rail.IsRailTypeAvailable);
    types.KeepValue(1);
    Rail.SetCurrentRailType(types.Begin());

    local current = root;
    while(current != null){
        if(current.rail != null){
            signs.Build(current.index, "rail");
            RailVectorBuilder.BuildRail(current.rail, current.index, current.origin);
        }else if(current.bridge != null){
            signs.Build(current.index, "bridge");
            RailVectorBuilder.BuildBridge(current.bridge, current.index, current.origin);
        }
        current = current.next;
    }
}