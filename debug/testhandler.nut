class DebugTestHandler extends CommandHandler {
    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !exit          To return to the default handler");
    }
    
    function OnCommand(command, argument, location){
        switch(command){
            case "info":
                this.ShowInfo(location);
            break;
            case "ref":
                local ref = Reference.FromTile(location);
                Log.Warning("Whoei: " + ref);
            break;
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
}