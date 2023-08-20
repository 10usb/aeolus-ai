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
        switch(command){
            case "clear":
                local signs = AISignList();
                Lists.Valuate(signs, AISign.RemoveSign);
            break;
            case "finder":
                this.debugging.SetHandler(FinderHandler());
            break;
            case "vector":
                this.debugging.SetHandler(VectorHandler());
            break;
            case "builder":
                this.debugging.SetHandler(BuilderHandler());
            break;
            case "segments":
                this.debugging.SetHandler(SegmentHandler());
            break;
            case "test":
                this.debugging.SetHandler(DebugTestHandler());
            break;
            default: return false;
        }

        return true;
    }
}