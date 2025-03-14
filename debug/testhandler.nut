class DebugTestHandler extends CommandHandler {
    tracer = null;
    cargo_id = 0;

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !exit          To return to the default handler");
    }
    
    function OnCommand(command, argument, location){
        switch(command){
            case "info": this.ShowInfo(location); break;
            case "ref":
                local ref = Reference.FromTile(location);
                Log.Warning("Whoei: " + ref);
            break;
            case "cargo": this.SetCargo(argument); break;
            case "town": this.BuildTown(location); break;
            default:
                Log.Error("Unknown command");
                this.PrintHelp();
        }

        return true;
    }

    function ShowInfo(location){
        Log.Info("[" + Tile.GetX(location) + "," + Tile.GetY(location) + "]");
        Log.Info("Industry ID: " + Industry.GetIndustryID(location));
        Log.Info("Station ID: " + Station.GetStationID(location));
        Log.Info("TownAuthority: " + Tile.GetTownAuthority(location));
        Log.Info("ClosestTown: " + Tile.GetClosestTown(location));
        Log.Info("GetOwner: " + Tile.GetOwner(location));
    }
    
    function SetCargo(argument){
        if(argument == "?"){
            Log.Info("Cargo's:");

            foreach(cargo_id, dummy in AICargoList()){
                Log.Info(" - " + cargo_id + " => " + Cargo.GetName(cargo_id));
            }
        }else{
            local cargo_id = argument.tointeger();
            if(!Cargo.IsValidCargo(cargo_id)){
                Log.Warning("Unknown cargo: " + cargo_id);
            }else{
                this.cargo_id = cargo_id;
                Log.Info("Set " + Cargo.GetName(cargo_id) + " (" + cargo_id + ")");
            }
        }
    }

    function BuildTown(location){
        local town_id = Tile.GetTownAuthority(location);
        local location = Town.GetLocation(town_id);
        Log.Info("Town: " + Town.GetName(town_id));
        Log.Info("IsRoad: " + Road.IsRoadTile(location));

        local cargo_id = Cargo.GetPassengerId();
        Log.Info("Acceptance: " + Tile.GetCargoAcceptance(location, cargo_id, 1, 1, 3));
        Log.Info("Production: " + Tile.GetCargoProduction(location, cargo_id, 1, 1, 3));

        //AISign.BuildSign(location, "Center");

        this.tracer = Tasks_Road_TownTracer(town_id, cargo_id, 100, true);
        this.EnqueueTask(this.tracer);
    }
}