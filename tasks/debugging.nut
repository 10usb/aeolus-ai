class Debugging extends Task {
    previous = null
    handler = null
}

function Debugging::GetName(){
    return "Debugging"
}

function Debugging::Run(){
    local list = AISignList();

    if(previous == null){
        previous = list;
        return this.Sleep(10);
    }

    local old = AIList();
    old.AddList(previous);
    old.RemoveList(list);
    if(old.Count() > 0){
        previous.RemoveList(old);
    }

    local diff = AIList();
    diff.AddList(list);
    diff.RemoveList(previous);

    foreach(sign_id, dummy in diff){
        local name = AISign.GetName(sign_id);

        if(name.slice(0, 1) == "!"){
            previous = list;
            this.Process(name, sign_id)
            break;
        }
    }

    return this.Sleep(10);
}

function Debugging::Process(command, sign_id){
    try {
        if(handler != null){
            if(!handler.OnCommand(command, sign_id)){
                handler = null;
                Log.Info("Debugging:");
            }
        }else{
            if(command == "!finder"){
                handler = FinderHandler();
                handler.SetParent(this.GetParent());
                AISign.RemoveSign(sign_id);
            }else if(command == "!clear"){
                local signs = AISignList();
                List.Valuate(signs, AISign.RemoveSign);
            }else if(command == "!vector"){

                local index = AISign.GetLocation(sign_id);

                local types = AIRailTypeList();
                types.Valuate(Rail.IsRailTypeAvailable);
                types.KeepValue(1);
                Rail.SetCurrentRailType(types.Begin());

                // local vector = RailVector();
                // vector.length = 7;

                // foreach(origin in [Tile.SLOPE_NE, Tile.SLOPE_NW, Tile.SLOPE_SW, Tile.SLOPE_SE]){
                //     local from = Tile.GetSlopeTileIndex(index, origin);
                //     AISign.BuildSign(from, Tile.GetSlopeName(origin));

                //     foreach(direction in [RailVector.DIRECTION_STRAIGHT, RailVector.DIRECTION_LEFT, RailVector.DIRECTION_RIGHT]){
                //         vector.direction = direction;

                //         local to = vector.GetTileIndex(index, origin);
                //         local next = vector.GetTileOrigin(origin);

                //         AISign.BuildSign(to, Tile.GetSlopeName(origin) + " - " + RailVector.GetDirectionName(direction) + " - " + Tile.GetSlopeName(next));

                //         Rail.BuildRail(from, index, to);
                //     }
                // }

                AISign.RemoveSign(sign_id);

                local vectors = [];

                local vector = RailVector();
                vector.length = 2;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 3;
                vector.direction = RailVector.DIRECTION_RIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_RIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 4;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 3;
                vector.direction = RailVector.DIRECTION_RIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 4;
                vector.direction = RailVector.DIRECTION_RIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 2;
                vector.direction = RailVector.DIRECTION_STRAIGHT;
                vectors.push(vector);

                local vector = RailVector();
                vector.length = 1;
                vector.direction = RailVector.DIRECTION_LEFT;
                vectors.push(vector);

                foreach(origin in [Tile.SLOPE_NE, Tile.SLOPE_NW, Tile.SLOPE_SW, Tile.SLOPE_SE]){
                    local current = index;

                    foreach(vector in vectors){    
                        RailVectorBuilder.Build(vector, current, origin);

                        current = vector.GetTileIndex(current, origin);
                        origin = vector.GetTileOrigin(origin);
                    }
                }
            }
        }
    }catch(err){
        Log.Error(err);
        Log.Info("I'm still alive");
    }
}