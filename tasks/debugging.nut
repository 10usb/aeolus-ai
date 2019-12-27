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
            handler.SetParent(this.GetParent());
            AISign.RemoveSign(sign_id);
        }
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