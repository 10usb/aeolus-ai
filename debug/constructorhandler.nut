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
        local producing = this.GetCargoListProducing(source);
        foreach(cargo_id, _ in producing)
            Log.Info(" - " + AICargo.GetName(cargo_id));

        Log.Info("Destination: " + destination);
        // Print accepted cargo
        local accepting = this.GetCargoListAccepting(destination);
        foreach(cargo_id, _ in accepting)
            Log.Info(" - " + AICargo.GetName(cargo_id));

        producing.KeepList(accepting);
        Log.Info("Transporable cargo ");
        foreach(cargo_id, _ in producing)
            Log.Info(" - " + AICargo.GetName(cargo_id));
        
        local distance = Tile.GetDistance(source.GetLocation(), destination.GetLocation());
        Log.Info("RealDistance: " + distance);
        local distance = Tile.GetDistanceManhattanToTile(source.GetLocation(), destination.GetLocation());
        Log.Info("ManhattanDistance: " + distance);

        local cargo_id = producing.Begin();

        local engines = AIList();

        // Trucks
        local trucks = AIEngineList(Vehicle.VT_ROAD);
        trucks.Valuate(Engine.GetCargoType);
        trucks.KeepValue(cargo_id);
        engines.AddList(trucks);

        //trucks.Valuate(Engine.GetEstimatedDays, distance, 0.90);
        
        // Trains
        local trains = AIEngineList(Vehicle.VT_RAIL);
        trains.Valuate(Engine.IsWagon);
        trains.KeepValue(0);
        trains.Valuate(Engine.CanPullCargo, cargo_id);
        trains.KeepValue(1);
        engines.AddList(trains);

        //trains.Valuate(Engine.GetEstimatedDays, distance, 0.70);
        


        Log.Info("Profit");
        foreach(engine_id, _ in engines){
            local profit = this.GetEstimatedProfit(engine_id, distance, cargo_id);
             Log.Info(Engine.GetName(engine_id) + ": " + profit);
        }

        // Calculate expected travel time for road, rail & air
        // Select best option based on travel time (80 days = optimal)
        // Calculate expected income
        // Calculate expected construction cost
        // Calculate expected operating cost
        // Calculate expected repay time
    }

    function Build(){
    }

    function GetCargoListProducing(reference){
        switch(reference.type){
            case Reference.INDUSTRY:
                return AICargoList_IndustryProducing(reference.id);
        }

        throw "Unsupported";
    }

    function GetCargoListAccepting(reference){
        switch(reference.type){
            case Reference.INDUSTRY:
                return AICargoList_IndustryAccepting(reference.id);
        }

        throw "Unsupported";
    }

    function GetEstimatedProfit(engine_id, distance, cargo_id){
        local days = 0;

        local type = Engine.GetVehicleType(engine_id);
        switch(type){
            case Vehicle.VT_ROAD:
                days = Engine.GetEstimatedDays(engine_id, distance, 0.90);
            break;
            case Vehicle.VT_RAIL:
                days = Engine.GetEstimatedDays(engine_id, distance, 0.70);
            break;
            default: throw "Unsupported type: " + type;
        }

        local capacity = Engine.GetCapacity(engine_id, cargo_id);

        local income = Cargo.GetCargoIncome(cargo_id, distance, days) * capacity;
        local times = (365 / (days * 2)).tointeger();
        local cost = 0;

        return (income * times) - Engine.GetRunningCost(engine_id);
    }
}