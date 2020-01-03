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
                local vector = RailVector();
                vector.length = 6;

                local index = AISign.GetLocation(sign_id);
                local x = AIMap.GetTileX(index);
                local y = AIMap.GetTileY(index);

                AISign.BuildSign(AIMap.GetTileIndex(x + 2, y), "x+");
                AISign.BuildSign(AIMap.GetTileIndex(x - 2, y), "x-");
                AISign.BuildSign(AIMap.GetTileIndex(x, y + 2), "y+");
                AISign.BuildSign(AIMap.GetTileIndex(x, y - 2), "y-");

                local types = AIRailTypeList();
                types.Valuate(Rail.IsRailTypeAvailable);
                types.KeepValue(1);
                Rail.SetCurrentRailType(types.Begin());

                foreach(origin in [Tile.SLOPE_NE, Tile.SLOPE_NW, Tile.SLOPE_SW, Tile.SLOPE_SE]){
                    local from = Tile.GetSlopeTileIndex(index, origin);
                    AISign.BuildSign(from, Tile.GetSlopeName(origin));

                    foreach(direction in [RailVector.DIRECTION_STRAIGHT, RailVector.DIRECTION_LEFT, RailVector.DIRECTION_RIGHT]){
                        vector.direction = direction;

                        local to = vector.GetTileIndex(index, origin);
                        local next = vector.GetTileOrigin(origin);

                        AISign.BuildSign(to, Tile.GetSlopeName(origin) + " - " + RailVector.GetDirectionName(direction) + " - " + Tile.GetSlopeName(next));

                        Rail.BuildRail(from, index, to);
                    }
                }
            }
        }
    }catch(err){
        Log.Error(err);
        Log.Info("I'm still alive");
    }
}

class CommandHandler {
    _parent = null;

    function GetParent(){
        return this._parent;
    }

    function SetParent(task){
        this._parent = task;
    }

    function OnCommand(command, sign_id);
}

class FinderHandler extends CommandHandler {
    finder = null;
    start = null;
    value = 0;

	constructor(){
	    Log.Info("Finder commands");
	    Log.Info(" - !start          Add a start tile");
        Log.Info(" - !value=?   Set value for a start/end tile");
        Log.Info(" - !from           Mark the spot a start tile comes from");
        Log.Info(" - !end              Add an end tile");
        Log.Info(" - !exclude   Exclude a tile for being processed");
        Log.Info(" - !go                 Start the finding process");
        finder = RailPathFinder();
    }
    function OnCommand(command, sign_id){
        if(command == "!start"){
            start = sign_id;
            AISign.SetName(sign_id, "OK");
        }else if(command == "!end"){
            finder.AddEndPoint(AISign.GetLocation(sign_id), value);
            value = 0;
            AISign.RemoveSign(sign_id);
        }else if(command == "!exclude"){
            finder.AddExclusion(AISign.GetLocation(sign_id));
            AISign.RemoveSign(sign_id);
        }else if(command == "!from"){
            if(start != null){
                local index = AISign.GetLocation(start);
                local towards = AISign.GetLocation(sign_id);

                if(Tile.GetDistanceManhattanToTile(index, towards) == 1){
                    finder.AddStartPoint(index, towards, value);
                    value = 0;
                }
                
                AISign.RemoveSign(start);
                start = null;
            }
            AISign.RemoveSign(sign_id);
        }else if(command == "!go"){
            AISign.RemoveSign(sign_id);
            Log.Info("Start");

            finder.Init();

            local limit = 50000;

            finder.BeginStep();
            while(limit-- > 0 && finder.Step());

            Log.Info("Done");
            finder.signs.Clean();
            Log.Info("Cleaned");

            local path = finder.GetPath();

            this.GetParent().EnqueueTask(RailPathBuilder(path));

            return false;
        }else if(command.slice(0, 7) == "!value="){
            try {
                value = command.slice(7).tointeger();
            }catch(err){
                value = 0;
            }
            AISign.RemoveSign(sign_id);
        }
        return true;
    }
}