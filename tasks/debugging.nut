class Tasks_Debugging extends Task {
    previous = null;
    handler = null;

	constructor(){
        handler = DefaultHandler(this);
    }

    function GetName(){
        return "Debugging";
    }

    function Run(){
        // Get the current list of signs
        local list = AISignList();

        // If there are any previous the it the first time.
        // Lets show some help
        if(previous == null){
            previous = list;
            handler.PrintHelp();
            return this.Sleep(10);
        }

        // Get a diff to get a list of new signs
        local old = AIList();
        old.AddList(previous);
        old.RemoveList(list);
        if(old.Count() > 0){
            Log.Warning("Removing old signs from list")
            previous.RemoveList(old);
        }

        local diff = AIList();
        diff.AddList(list);
        diff.RemoveList(previous);
        
        // Now get the first-one that matches the command syntax
        foreach(sign_id, dummy in diff){
            local name = AISign.GetName(sign_id);

            if(name.slice(0, 1) != "!")
                continue;
            
            local location = AISign.GetLocation(sign_id);

            local start = 1;
            local offset = null;

            do {
                offset = name.find(";", start);
                local end = offset == null ? name.len() : offset
                local command = name.slice(start, end);

                try {
                    if(!this.Process(command, location))
                        break;
                }catch(err){
                    Log.Error(err);
                    Log.Info("I'm still alive");
                }
                start = end + 1;
            }while(offset != null);

            AISign.RemoveSign(sign_id);
            previous = AISignList();
            break;
        }

        return this.Sleep(10);
    }

    function Process(command, location){
        local argument = null;
        local offset = command.find("=");
        if(offset!= null){
            argument = command.slice(offset + 1);
            command = command.slice(0, offset);
        }
        
        if(command == "")
            return true;

        switch(command){
            case "exit":
                handler = DefaultHandler(this);
                handler.PrintHelp();
            break;
            case "clear":
                local signs = AISignList();
                Lists.Valuate(signs, AISign.RemoveSign);
            break;
            case "help": handler.PrintHelp(); break;
            default:
                if(!handler.OnCommand(command, argument, location)){
                    handler = DefaultHandler(this);
                    handler.PrintHelp();
                    return false;
                }
            break;
        }

        return true;
    }

    function SetHandler(handler){
        Log.Info("Setting handler");
        this.handler = handler;
        this.handler.SetParent(this.GetParent());
        this.handler.PrintHelp();
    }
}