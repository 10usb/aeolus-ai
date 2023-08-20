class DebugConstructorHandler extends CommandHandler {
    source = null;
    destination = null;

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
        Log.Info(" - !go            Start connecting the source to the destination");
    }
    
    function OnCommand(command, argument, location){
        switch(command){
            case "source":
                source = Reference.FromTile(location);
                Log.Info("Set source to: " + source);
            break;
            case "destination":
                destination = Reference.FromTile(location);
                Log.Info("Set destination to: " + destination);
            break;
            case "analyze": this.Analyze(); break;
            case "build": this.Build(); break;
            default:
                Log.Error("Unknown command");
                this.PrintHelp();
        }

        return true;
    }

    function Analyze(){
        Log.Info("Source: " + source);
        Log.Info("Destination: " + destination);
    }

    function Build(){
    }
}