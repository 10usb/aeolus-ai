class BuilderHandler extends CommandHandler {
    source_id = null;
    destination_id = null;
    endpoints = null

	constructor(){
	    Log.Info("Build commands");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
        Log.Info(" - !endpoints     Mark the end points");
        Log.Info(" - !station       Set destination industry");
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
        }else if(command == "!station"){
            AISign.RemoveSign(sign_id);
            BuildSourceStation();
        }else if(command == "!endpoints"){
            AISign.RemoveSign(sign_id);
            EndPoints();
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

        vertical.Valuate(Tile.IsFlatRectangle, 1, length);
        vertical.KeepValue(1);

        local horizontal = AITileList();
        horizontal.AddRectangle(Tile.GetIndex(x1 - (length - 1), y2), Tile.GetIndex(x1 - 1, y1));
        horizontal.AddList(tiles);
        
        horizontal.Valuate(Tile.IsBuildableRectangle, length, 1);
        horizontal.KeepValue(1);

        horizontal.Valuate(Tile.IsFlatRectangle, length, 1);
        horizontal.KeepValue(1);

        // AISign.BuildSign(origin, "Origin");
        // Lists.Valuate(vertical, AISign.BuildSign, "V");
        // Lists.Valuate(horizontal, AISign.BuildSign, "H");
        
        if(this.endpoints == null) this.EndPoints();


        FindStation(horizontal, -1, 0);
    }

    function EndPoints(){
        local origin = Industry.GetLocation(source_id);
        local end = Industry.GetLocation(destination_id);

        local distance = Tile.GetDistance(origin, end);
        local angle = Tile.GetAngle(end, origin);

        this.endpoints = List();

        local range = max(10, (100 - (distance / 2.0) + 0.5).tointeger());


        if(distance < 35) distance = 35;
        for(local j = 30; j <= 32; j++){
            this.endpoints.AddItem(Tile.GetAngledIndex(end, angle, distance - j), 0);
            for(local i = 1; i < range; i+=1){
                this.endpoints.AddItem(Tile.GetAngledIndex(end, angle - i, distance - j), 0);
                this.endpoints.AddItem(Tile.GetAngledIndex(end, angle + i, distance - j), 0);
            }
        }

        // Lists.Valuate(this.endpoints, AISign.BuildSign, "+");
    }

    function FindStation(tiles, ox, oy){
        local finder = RailPathFinder();

        foreach(towards, _ in tiles){
            local index = Tile.GetTranslatedIndex(towards, ox, oy);
            finder.AddStartPoint(index, towards, 0);
        }
        
        foreach(index, _ in this.endpoints){
            finder.AddEndPoint(index, 0);
        }

        finder.Init();

        local limit = 50000;

        finder.BeginStep();
        while(limit-- > 0 && finder.Step());

        Log.Info("Value: " + finder.GetBest());

        local path = finder.GetPath();

        this.GetParent().EnqueueTask(RailPathBuilder(path));
    }
}