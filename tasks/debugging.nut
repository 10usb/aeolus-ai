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
        }
    }else{
        if(command == "!finder"){
            handler = FinderHandler();
        }
    }
}

class CommandHandler {
    function OnCommand(command, sign_id);
}

class FinderHandler extends CommandHandler {
    finder = null;

	constructor(){
	    Log.Info("Started finder handler");
        finder = RailPathFinder();
    }
    function OnCommand(command, sign_id){
	    Log.Info("Start");
        finder.Enqueue(RailPathNode(AISign.GetLocation(sign_id), null, 0));

        local limit = 1000;

        while(limit-- > 0 && finder.Step());

	    Log.Info("Done");
        return true;
    }
}