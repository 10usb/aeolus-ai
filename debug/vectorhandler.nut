class VectorHandler extends CommandHandler {
    finder  = null;
    path    = null;
    vectors = null;
    signs   = null;

    segments = null;
    length   = null;
    index    = null;
    origin   = null;

	constructor(){
	    Log.Info("Vector commands");
        Log.Info(" - !compass   Build a vectors in each direction from each origin");
        Log.Info(" - !pattern   Build a pattern from vectors");
	    Log.Info(" - !finder    Start a path finder to use");
        Log.Info(" - !add       Append a tile to the end of the path");
        Log.Info(" - !path      Turn the path into vectors");
        Log.Info(" - !optimize  optimize the vectors");
        Log.Info(" - !build     Build the vectors");
        Log.Info(" - !exit");

        this.path = [];
        this.signs = Signs();
        this.segments = [];
    }
    
    function OnCommand(command, location){
        if(finder != null){
            if(!finder.OnCommand(command, location)){
                this.path = finder.path;
                this.finder = null;
            }
        }else if(command == "!exit"){
            return false;
        }else if(command == "!compass"){
            this.Compass(location);
        }else if(command == "!pattern"){
            this.Pattern(location);
        }else if(command == "!finder"){
            this.finder = FinderHandler(false);
            this.finder.SetParent(this.GetParent());
        }else if(command == "!add"){
            this.path.push(location);
            this.signs.Build(index, "P" + path.len());
        }else if(command == "!path"){
            this.vectors = RailPathVectorizer();
            this.vectors.Append(this.path);

            local queue = TaskQueue();
            queue.EnqueueTask(this.vectors);
            queue.EnqueueTask(PrintInfo("Path vectorized"));
            this.GetParent().EnqueueTask(queue);
        }else if(command == "!optimize"){
            local optimizer = RailVectorOptimizer(this.vectors.GetRoot());

            local queue = TaskQueue();
            queue.EnqueueTask(optimizer);
            queue.EnqueueTask(PrintInfo("Vectors optimized"));
            this.GetParent().EnqueueTask(queue);
        }else if(command == "!build"){
            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            this.GetParent().EnqueueTask(RailSegmentBuilder(railType, this.vectors.GetRoot(), true, 0));
        }

        return true;
    }
    
    function Compass(index){
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
    
    function Pattern(index){
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