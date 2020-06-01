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

        Log.Info(" - !segment=? Add a segment with a given length");
        Log.Info(" - !origin    Define the origin of the segment");
        Log.Info(" - !towards   Define the tile it should point to");
        Log.Info(" - !intersect Tries to intersect the to segments");

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
        }else if(command == "!compass"){
            this.Compass(location);
        }else if(command == "!pattern"){
            this.Pattern(location);
        }else if(command == "!finder"){
            this.finder = FinderHandler(false);
            this.finder.SetParent(this.GetParent());
        }else if(command == "!exit"){
            return false;
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
            RailVectorBuilder.BuildChain(this.vectors.GetRoot());
        }else if(command.len() > 9 && command.slice(0, 9) == "!segment="){
            try {
                this.length = command.slice(9).tointeger();
            }catch(err){
                this.length = 1;
            }
            this.index = AISign.BuildSign(location, "OK");;
        }else if(command == "!origin"){
            Log.Info("Adding origin");
            this.origin = location;
        }else if(command == "!towards"){
            local segment = RailVectorSegment.Create(this.origin, AISign.GetLocation(this.index), location);
            segment.rail.length = length;
            this.segments.push(segment);

            AISign.RemoveSign(this.index);

            this.signs.Build(segment.index, "L:" + segment.rail.length);
            this.signs.Build(this.origin, "O");
            this.signs.Build(location, "T");
        }else if(command == "!intersect"){
            this.Intersect(this.segments[0], this.segments[1]);
        }
        return true;
    }
    
    // To intersect to segments we use the most outwards entries of both and
    // get the difference of x and y. Of this rectangle we take the square by
    // using the shortes of x and y. This wil be the diagonal part, the
    // remaining difference of x and y will be the straight part
    function Intersect(from, towards){
        local terminal = towards.GetExit();

        local difference = from.GetVector().difference(terminal.GetVector());

        if(from.origin == Tile.GetComplementSlope(terminal.origin)){
            // When the origin is equal to the compliment the square can be on
            // either sides, thus we need to test both. try-ing to maintain the
            // current diagonal en straight state
        }else if(from.origin != towards.origin){
            
        }
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