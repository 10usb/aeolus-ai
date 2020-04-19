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
    
    function OnCommand(command, sign_id){
        if(command == "!start"){
            start = sign_id;
            AISign.SetName(sign_id, "OK");
        }else if(command == "!end"){
            finder.AddEndPoint(AISign.GetLocation(sign_id), value);
            value = 0;
            AISign.RemoveSign(sign_id);
        }else if(command == "!exclude"){
            finder.AddExclusion(AISign.GetLocation(sign_id));
            AISign.RemoveSign(sign_id);
        }else if(command == "!from"){
            if(start != null){
                local index = AISign.GetLocation(start);
                local towards = AISign.GetLocation(sign_id);

                if(Tile.GetDistanceManhattanToTile(index, towards) == 1){
                    finder.AddStartPoint(index, towards, value);
                    value = 0;
                }
                
                AISign.RemoveSign(start);
                start = null;
            }
            AISign.RemoveSign(sign_id);
        }else if(command == "!go"){
            AISign.RemoveSign(sign_id);
            Log.Info("Start");

            finder.Init();

            local limit = 50000;

            finder.BeginStep();
            while(limit-- > 0 && finder.Step());

            Log.Info("Done");
            finder.signs.Clean();
            Log.Info("Cleaned");

            this.path = finder.GetPath();

            if(this.build) this.GetParent().EnqueueTask(RailPathBuilder(path));

            return false;
        }else if(command.len() > 7 && command.slice(0, 7) == "!value="){
            try {
                value = command.slice(7).tointeger();
            }catch(err){
                value = 0;
            }
            AISign.RemoveSign(sign_id);
        }
        return true;
    }
}