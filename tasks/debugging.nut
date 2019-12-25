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
    if(handler != null){
        if(!handler.OnCommand(command, sign_id)){
            handler = null;
	        Log.Info("Debugging:");
        }
    }else{
        if(command == "!finder"){
            handler = FinderHandler();
            AISign.RemoveSign(sign_id);
        }
    }
}

class CommandHandler {
    function OnCommand(command, sign_id);
}

class FinderHandler extends CommandHandler {
    finder = null;
    start = null;

	constructor(){
	    Log.Info("Started finder handler");
        finder = RailPathFinder();
    }
    function OnCommand(command, sign_id){
        if(command == "!start"){
            start = sign_id;
            AISign.SetName(sign_id, "OK");
        }else if(command == "!end"){
            finder.AddEndPoint(AISign.GetLocation(sign_id), 0);
            AISign.RemoveSign(sign_id);
        }else if(command == "!from"){
            if(start != null){
                local index = AISign.GetLocation(start);
                local towards = AISign.GetLocation(sign_id);

                if(Tile.GetDistanceManhattanToTile(index, towards) == 1){
                    finder.AddStartPoint(index, towards, 0);
                }
                
                AISign.RemoveSign(start);
                start = null;
            }
            AISign.RemoveSign(sign_id);
        }else if(command == "!go"){
            AISign.RemoveSign(sign_id);
            Log.Info("Start");

            finder.Init();

            local limit = 5000;

            while(limit-- > 0 && finder.Step());

            Log.Info("Done");
            finder.signs.Clean();
            Log.Info("Cleaned");

            finder.GetPath();
            Controller.Sleep(100);
            finder.signs.Clean();

            return false;
        }
        return true;
    }
}