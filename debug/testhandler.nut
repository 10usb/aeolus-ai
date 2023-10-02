class DebugTestHandler extends CommandHandler {
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

    function BuildTown(location){
        local town_id = Tile.GetTownAuthority(location);
        local location = Town.GetLocation(town_id);
        Log.Info("Town: " + Town.GetName(town_id));
        Log.Info("IsRoad: " + Road.IsRoadTile(location));

        local cargo_id = Cargo.GetPassengerId();
        Log.Info("Acceptance: " + Tile.GetCargoAcceptance(location, cargo_id, 1, 1, 3));
        Log.Info("Production: " + Tile.GetCargoProduction(location, cargo_id, 1, 1, 3));

        //AISign.BuildSign(location, "Center");

        local task = Tasks_Road_TownTracer(town_id, cargo_id, 100);
        this.GetParent().EnqueueTask(task);
    }
}