class FinderHandler extends CommandHandler {
    finder = null;
    start = null;
    value = 0;
    path = null;
    build = true;
    exclusions = null;

	constructor(build = true){
	    Log.Info("Finder commands");
	    Log.Info(" - !start          Add a start tile");
        Log.Info(" - !value=?   Set value for a start/end tile");
        Log.Info(" - !from           Mark the spot a start tile comes from");
        Log.Info(" - !end              Add an end tile");
        Log.Info(" - !exclude   Exclude a tile for being processed");
        Log.Info(" - !go                 Start the finding process");
        finder = RoadPathFinder();
        finder.debug = true;

        this.build = build;
    }
    
    function OnCommand(command, argument, location){
        if(command == "start"){
            start = AISign.BuildSign(location, "OK");
        }else if(command == "end"){
            finder.AddEndPoint(location, value);
            value = 0;
        }else if(command == "exclude"){
            finder.AddExclusion(location, this.exclusions);
        }else if(command == "from"){
            if(start != null){
                local index = AISign.GetLocation(start);
                local towards = location;

                if(Tile.GetDistanceManhattanToTile(index, towards) == 1){
                    finder.AddStartPoint(index, towards, value);
                    value = 0;
                }
                
                AISign.RemoveSign(start);
                start = null;
                exclusions = index;
            }
        }else if(command == "go"){
            Log.Info("Start");

            finder.Init();

            local limit = 50000;

            finder.BeginStep();
            while(limit-- > 0 && finder.Step());

            Log.Info("Done");
            finder.signs.Clean();
            Log.Info("Cleaned");

            this.path = finder.GetPath();
            Log.Info("Path size" + this.path.len());

            // local types = AIRailTypeList();
            // types.Valuate(Rail.IsRailTypeAvailable);
            // types.KeepValue(1);
            // local railType = types.Begin();

            local builder = Tasks_RoadPathBuilder(Road.ROADTYPE_ROAD);
            builder.Append(path);
            if(this.build){
                Log.Info("Building path");
                this.EnqueueTask(builder);
            }

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