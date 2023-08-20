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
        // Print source cargo

        Log.Info("Destination: " + destination);
        // Print accepted cargo
        
        local distance = Tile.GetDistance(source.GetLocation(), destination.GetLocation());
        Log.Info("RealDistance: " + distance);
        local distance = Tile.GetDistanceManhattanToTile(source.GetLocation(), destination.GetLocation());
        Log.Info("ManhattanDistance: " + distance);

        local trucks = AIEngineList(Vehicle.VT_ROAD);
        trucks.Valuate(Engine.GetEstimatedDays, distance, 0.90);

        foreach(engine_id, days in trucks){
             Log.Info(Engine.GetName(engine_id) + ": " + days);
        }

        // 
        // Calculate expected travel time for road, rail & air
        // Select best option based on travel time (80 days = optimal)
        // Calculate expected income
        // Calculate expected construction cost
        // Calculate expected operating cost
        // Calculate expected repay time
    }

    function Build(){
    }
}