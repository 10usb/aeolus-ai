class SegmentHandler extends CommandHandler {
    root     = null;
    origin   = null;


    path    = null;
    vectors = null;
    signs   = null;

    segments = null;
    length   = null;
    index    = null;
    

	constructor(){
	    Log.Info("Segment commands");
        Log.Info(" - !root      Define the tile the root segment starts");
        Log.Info(" - !origin    Define the origin for the root segment");
        Log.Info(" - !segment=? Add a segment with a given length");
        Log.Info(" - !optimize  Tries to optimize the segments");
        Log.Info(" - !exit");

        this.root     = null;
        this.origin   = null;
    }
    
    function OnCommand(command, location){
        if(command == "!exit"){
            return false;
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
            RailVectorIntersecter.Intersect(this.segments[0], this.segments[1]);

            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            this.GetParent().EnqueueTask(RailSegmentBuilder(railType, this.segments[0], true));
            this.segments = [];
        }
        return true;
    }
}