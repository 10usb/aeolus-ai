class VectorHandler extends CommandHandler {
    finder  = null;
    path    = null;
    vectors = null;
    signs   = null;

	constructor(){
	    Log.Info("Vector commands");
        Log.Info(" - !compass");
        Log.Info(" - !pattern");
	    Log.Info(" - !finder");
        Log.Info(" - !add");
        Log.Info(" - !path");
        Log.Info(" - !build");
        Log.Info(" - !exit");

        this.path = [];
		this.signs = Signs();
    }
    
    function OnCommand(command, sign_id){
        if(finder != null){
            if(!finder.OnCommand(command, sign_id)){
                this.path = finder.path;
                this.finder = null;
            }
        }else if(command == "!compass"){
            this.Compass(sign_id);
            AISign.RemoveSign(sign_id);
        }else if(command == "!pattern"){
            this.Pattern(sign_id);
            AISign.RemoveSign(sign_id);
        }else if(command == "!finder"){
            this.finder = FinderHandler(false);
            this.finder.SetParent(this.GetParent());
            AISign.RemoveSign(sign_id);
        }else if(command == "!exit"){
            AISign.RemoveSign(sign_id);
            return false;
        }else if(command == "!add"){
            local index = AISign.GetLocation(sign_id);
            AISign.RemoveSign(sign_id);
            this.path.push(index);
            this.signs.Build(index, "P" + path.len());
        }else if(command == "!path"){
            AISign.RemoveSign(sign_id);
            
            this.vectors = RailPathVectorizer();
            this.vectors.Append(this.path);

            local queue = TaskQueue();
            queue.EnqueueTask(this.vectors);
            queue.EnqueueTask(PrintInfo("Path vectorized"));
            this.GetParent().EnqueueTask(queue);
        }else if(command == "!optimize"){
            AISign.RemoveSign(sign_id);
            local optimizer = RailVectorOptimizer(this.vectors.GetRoot());

            local queue = TaskQueue();
            queue.EnqueueTask(optimizer);
            queue.EnqueueTask(PrintInfo("Vectors optimized"));
            this.GetParent().EnqueueTask(queue);
        }else if(command == "!build"){
            AISign.RemoveSign(sign_id);
            RailVectorBuilder.BuildChain(this.vectors.GetRoot());
        }
        return true;
    }
    
    function Compass(sign_id){
        local index = AISign.GetLocation(sign_id);

        local types = AIRailTypeList();
        types.Valuate(Rail.IsRailTypeAvailable);
        types.KeepValue(1);
        Rail.SetCurrentRailType(types.Begin());

        local vector = RailVector();
        vector.length = 7;

        foreach(origin in [Tile.SLOPE_NE, Tile.SLOPE_NW, Tile.SLOPE_SW, Tile.SLOPE_SE]){
            local from = Tile.GetSlopeTileIndex(index, origin);
            AISign.BuildSign(from, Tile.GetSlopeName(origin));

            foreach(direction in [RailVector.DIRECTION_STRAIGHT, RailVector.DIRECTION_LEFT, RailVector.DIRECTION_RIGHT]){
                vector.direction = direction;

                local to = vector.GetTileIndex(index, origin);
                local next = vector.GetTileOrigin(origin);

                AISign.BuildSign(to, Tile.GetSlopeName(origin) + " - " + RailVector.GetDirectionName(direction) + " - " + Tile.GetSlopeName(next));

                Rail.BuildRail(from, index, to);
            }
        }
    }
    
    function Pattern(sign_id){
        local index = AISign.GetLocation(sign_id);

        local types = AIRailTypeList();
        types.Valuate(Rail.IsRailTypeAvailable);
        types.KeepValue(1);
        Rail.SetCurrentRailType(types.Begin());



        local vectors = [];

        local vector = RailVector();
        vector.length = 2;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 3;
        vector.direction = RailVector.DIRECTION_RIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_RIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 4;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 3;
        vector.direction = RailVector.DIRECTION_RIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 4;
        vector.direction = RailVector.DIRECTION_RIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 2;
        vector.direction = RailVector.DIRECTION_STRAIGHT;
        vectors.push(vector);

        local vector = RailVector();
        vector.length = 1;
        vector.direction = RailVector.DIRECTION_LEFT;
        vectors.push(vector);

        foreach(origin in [Tile.SLOPE_NE, Tile.SLOPE_NW, Tile.SLOPE_SW, Tile.SLOPE_SE]){
            local current = index;

            foreach(vector in vectors){    
                RailVectorBuilder.Build(vector, current, origin);

                current = vector.GetTileIndex(current, origin);
                origin = vector.GetTileOrigin(origin);
            }
        }
    }
}