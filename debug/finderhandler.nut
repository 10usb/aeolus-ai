class FinderHandler extends CommandHandler {
    finder = null;
    start = null;
    value = 0;
    path = null;
    build = true;

	constructor(build = true){
	    Log.Info("Finder commands");
	    Log.Info(" - !start          Add a start tile");
        Log.Info(" - !value=?   Set value for a start/end tile");
        Log.Info(" - !from           Mark the spot a start tile comes from");
        Log.Info(" - !end              Add an end tile");
        Log.Info(" - !exclude   Exclude a tile for being processed");
        Log.Info(" - !go                 Start the finding process");
        finder = RailPathFinder();
        finder.debug = true;

        this.build = build;
    }
    
    function OnCommand(command, location){
        if(command == "!start"){
            start = AISign.BuildSign(location, "OK");
        }else if(command == "!end"){
            finder.AddEndPoint(location, value);
            value = 0;
        }else if(command == "!exclude"){
            finder.AddExclusion(location);
        }else if(command == "!from"){
            if(start != null){
                local index = AISign.GetLocation(start);
                local towards = location;

                if(Tile.GetDistanceManhattanToTile(index, towards) == 1){
                    finder.AddStartPoint(index, towards, value);
                    value = 0;
                }
                
                AISign.RemoveSign(start);
                start = null;
            }
        }else if(command == "!go"){
            Log.Info("Start");

            finder.Init();

            local limit = 50000;

            finder.BeginStep();
            while(limit-- > 0 && finder.Step());

            Log.Info("Done");
            finder.signs.Clean();
            Log.Info("Cleaned");

            this.path = finder.GetPath();

            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            local builder = RailPathBuilder(railType);
            builder.Append(path);
            if(this.build) this.GetParent().EnqueueTask(builder);

            return false;
        }else if(command.len() > 7 && command.slice(0, 7) == "!value="){
            try {
                value = command.slice(7).tointeger();
            }catch(err){
                value = 0;
            }
        }
        return true;
    }
}