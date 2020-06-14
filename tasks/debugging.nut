class Debugging extends Task {
    previous = null
    handler = null

    function GetName(){
        return "Debugging";
    }

    function Run(){
        local list = AISignList();

        if(previous == null){
            previous = list;
            PrintHelp();
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
                this.Process(name, AISign.GetLocation(sign_id));
                AISign.RemoveSign(sign_id);

                previous = AISignList();
                break;
            }
        }

        return this.Sleep(10);
    }

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !clear         Clear all signal posts");
        Log.Info(" - !finder        To find a path");
        Log.Info(" - !vector        Use vectors to build rail");
        Log.Info(" - !builder       Start the builder");
        Log.Info(" - !segment       Segments & vectors");
    }

    function Process(command, location){
        try {
            if(handler != null){
                if(!handler.OnCommand(command, location)){
                    handler = null;
                    PrintHelp();
                }
            }else{
                if(command == "!clear"){
                    local signs = AISignList();
                    Lists.Valuate(signs, AISign.RemoveSign);
                }else if(command == "!finder"){
                    handler = FinderHandler();
                    handler.SetParent(this.GetParent());
                }else if(command == "!vector"){
                    handler = VectorHandler();
                    handler.SetParent(this.GetParent());
                }else if(command == "!builder"){
                    handler = BuilderHandler();
                    handler.SetParent(this.GetParent());
                }else if(command == "!segment"){
                    handler = SegmentHandler();
                    handler.SetParent(this.GetParent());
                }
            }
        }catch(err){
            Log.Error(err);
            Log.Info("I'm still alive");
        }
    }
}