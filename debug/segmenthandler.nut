class SegmentHandler extends CommandHandler {
    start    = null;
    origin   = null;

    root     = null;
    current  = null;

	constructor(){
	    Log.Info("Segment commands");
        Log.Info(" - !start     Define the starting tile");
        Log.Info(" - !origin    Define the origin for the root segment");
        Log.Info(" - !segment=? Add a segment with a given length");
        Log.Info(" - !optimize  Tries to optimize the segments");
        Log.Info(" - !exit");

        this.start    = null;
        this.origin   = null;
        this.root     = null;
        this.current  = null;
    }
    
    function OnCommand(command, argument, location){
        if(command == "!exit"){
            return false;
        }else if(command == "!start"){
            this.start = AISign.BuildSign(location, "OK");
        }else  if(command == "!origin"){
            this.origin = AISign.BuildSign(location, "O");
        }else if(command.len() > 9 && command.slice(0, 9) == "!segment="){
            local length = null;
            try {
                length = command.slice(9).tointeger();
            }catch(err){
            }
            
            if(length == null){
                Log.Warn("Failed to parse length");
                return true;
            }

            local segment = RailVectorSegment.Create(AISign.GetLocation(this.origin), AISign.GetLocation(this.start), location);
            segment.rail.length = length;

            local origin = segment.rail.GetTileIndex(segment.index, segment.origin, segment.rail.length - 1);
            local next = segment.rail.GetTileIndex(segment.index, segment.origin, segment.rail.length);
            
            this.origin = AISign.BuildSign(origin, "O");
            this.start = AISign.BuildSign(next, "N");

            if(this.current == null){
                this.root = segment;
                this.current = segment;
            }else{
                this.current.next = segment;
                this.current = segment;
            }
        }else if(command == "!build"){
            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            this.GetParent().EnqueueTask(RailSegmentBuilder(railType, this.root, true, 0));
        }else if(command == "!optimize"){
            local optimizer = RailVectorOptimizer(this.root, true);

            local queue = TaskQueue();
            queue.EnqueueTask(optimizer);
            queue.EnqueueTask(PrintInfo("Optimized"));
            this.GetParent().EnqueueTask(queue);
        }else if(command == "!intersect"){
            RailVectorIntersecter.Intersect(this.segments[0], this.segments[1].GetExit());

            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            this.GetParent().EnqueueTask(RailSegmentBuilder(railType, this.segments[0], true, 0));
            this.segments = [];
        }
        return true;
    }
}