class DefaultHandler extends CommandHandler {
    debugging = null;

	constructor(debugging){
        this.debugging = debugging;
    }

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !exit          To return to the default handler");
        Log.Info(" - !help          To print the help of the current handler");
        Log.Info(" - !clear         Clear all signal posts");
        Log.Info(" - !finder        To find a path");
        Log.Info(" - !vector        Use vectors to build rail");
        Log.Info(" - !builder       Start the builder");
        Log.Info(" - !segments      Segments & vectors");
    }
    
    function OnCommand(command, argument, location){
        if(command == "clear"){
            local signs = AISignList();
            Lists.Valuate(signs, AISign.RemoveSign);
        }else if(command == "finder"){
            this.debugging.SetHandler(FinderHandler());
        }else if(command == "vector"){
            this.debugging.SetHandler(VectorHandler());
        }else if(command == "builder"){
            this.debugging.SetHandler(BuilderHandler());
        }else if(command == "segments"){
            this.debugging.SetHandler(SegmentHandler());
        }else return false;

        return true;
    }
}