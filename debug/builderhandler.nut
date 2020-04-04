class BuilderHandler extends CommandHandler {
    source_id = null;
    destination_id = null;

	constructor(){
	    Log.Info("Build commands");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
    }
    
    function OnCommand(command, sign_id){
        if(command == "!exit"){
            AISign.RemoveSign(sign_id);
            return false;
        }else if(command == "!source" || command == "!destination"){
            local location = AISign.GetLocation(sign_id);
            AISign.RemoveSign(sign_id);

            local industry_id = Industry.GetIndustryID(location);

            if(!Industry.IsValidIndustry(industry_id)){
                Log.Info("No industry found");
            }else{
                if(command == "!source"){
                    this.source_id = industry_id;
                    Log.Info("Source: " + Industry.GetName(industry_id));
                }else{
                    this.destination_id = industry_id;
                    Log.Info("Destination: " + Industry.GetName(industry_id));
                }
            }
        }else if(command == "!go"){
            AISign.RemoveSign(sign_id);
            BuildSourceStation();
        }
        return true;
    }

    function BuildSourceStation(){
        local radius = Station.GetCoverageRadius(Station.STATION_TRAIN);
        local length = 4;
        local origin = Industry.GetLocation(source_id);
        local industry_type = Industry.GetIndustryType(source_id);
        local cargos = IndustryType.GetProducedCargo(industry_type);

        Log.Info("Radius of station: " + radius);
        Log.Info("Industry type: " + IndustryType.GetName(industry_type));
        Log.Info("Industry raw: " + IndustryType.IsRawIndustry(industry_type));

        foreach(cargo_id, dummy in cargos){
            Log.Info(" - " + Cargo.GetName(cargo_id));
        }

        AISign.BuildSign(origin, "Origin");

        local tiles = AITileList_IndustryProducing(source_id, radius);

        tiles.Valuate(Tile.GetX);
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_ASCENDING);
        local x1 = tiles.GetValue(tiles.Begin());
        
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_DESCENDING);
        local x2 = tiles.GetValue(tiles.Begin());

        tiles.Valuate(Tile.GetY);
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_ASCENDING);
        local y1 = tiles.GetValue(tiles.Begin());

        tiles.Sort(List.SORT_BY_VALUE, List.SORT_DESCENDING);
        local y2 = tiles.GetValue(tiles.Begin());
        

        local vertical = AITileList();
        vertical.AddRectangle(Tile.GetIndex(x2, y1 - (length - 1)), Tile.GetIndex(x1, y1 - 1));
        vertical.AddList(tiles);

        vertical.Valuate(Tile.IsBuildableRectangle, 1, length);
        vertical.KeepValue(1);

        local horizontal = AITileList();
        horizontal.AddRectangle(Tile.GetIndex(x1 - (length - 1), y2), Tile.GetIndex(x1 - 1, y1));
        horizontal.AddList(tiles);
        
        horizontal.Valuate(Tile.IsBuildableRectangle, length, 1);
        horizontal.KeepValue(1);
        

        Lists.Valuate(vertical, AISign.BuildSign, "V");
        Lists.Valuate(horizontal, AISign.BuildSign, "H");
    }
}