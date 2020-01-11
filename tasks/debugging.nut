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
            this.Process(name, sign_id);
            previous = AISignList();
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
                handler = VectorHandler();
                handler.SetParent(this.GetParent());
                AISign.RemoveSign(sign_id);
            }
        }
    }catch(err){
        Log.Error(err);
        Log.Info("I'm still alive");
    }
}