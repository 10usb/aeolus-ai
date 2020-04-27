/**
 * This task must be initialized with a path of at least 2 tile and it will
 * build a track to its destination. It does this with search steps of the
 * specified size. It only builds 2/3 of each step to ensure that the joint of
 * each step is smoothed out. It stops building at the same distance from the
 * destination. It returns the tile index of its terminal.
 */
class RailPathExtender extends Task {
	static INITIALIZE = 0;
    static START_SEARCH = 1;
    static ADD_ENDPOINTS = 2;
    static INIT_FINDER = 3;
    static DO_STEP = 4;
    static GET_SLICE = 5;
    static FINALIZE = 6
    static DONE = 7;
    
    path = null;
    destination = null;
    size = null;

    startDate = null;
    endDate = null;

    finder = null;
    state = 0;
    steps = 0;

	constructor(path, destination, size){
        local end = max(2, path.len() * 2 / 3) - 1;
        // If end points to the start of a bridge ramp move to the tile before
        if(Tile.GetDistanceManhattanToTile(path[end], path[end + 1]) > 1) end--;
        // If end points to the end of a bridge ramp move to the tile before the bridge
        if(Tile.GetDistanceManhattanToTile(path[end - 1], path[end]) > 1) end-=2;
        this.path = path.slice(0, end + 1);
        this.destination = destination;
        this.size = size;
    }

    function GetName(){
        return "RailPathExtender";
    }
    
    function Run(){
        if(state == INITIALIZE){
            this.startDate = Date.GetCurrentDate();
            state = START_SEARCH;
            return true;
        }

        if(state == START_SEARCH){
            Log.Info("Starting search for extending path");
            this.finder = RailPathFinder();
            // this.finder.debug = true;
            this.finder.AddStartPoint(this.path[this.path.len() - 1], this.path[this.path.len() - 2], 0);
            state = ADD_ENDPOINTS;
            return true;
        }

        if(state == ADD_ENDPOINTS){
            Log.Info("Add the endpoints to the finder");
            local origin = this.path[this.path.len() - 1];
            local distance = Tile.GetDistance(origin, this.destination);

            // Because we only build 2/3 of the path we're going to search 1/3
            // further into the end-zone (7/9 = 2.333/3 to make a marginal difference)
            if(distance < (this.size  * 7 / 9)){
                state = FINALIZE;
                return true;
            }else{
                Log.Info("Remaining distance " + distance);
            }

            this.AddEndPoints(distance, Tile.GetAngle(this.destination, origin));
            state = INIT_FINDER;
            return true;
        }
    
        if(this.state == INIT_FINDER){
            Log.Info("Initialize finder");
            this.finder.Init();
            this.steps = 0;
            this.state = DO_STEP;
            return true;
        }

        if(this.state == DO_STEP){
            this.finder.BeginStep();
            local limit = 35;
            while(limit-- > 0 && this.steps++ < 50000){
                if(!this.finder.Step()){
                    this.state = GET_SLICE;
                    return true;
                }
            }
    
            return true;
        }
    
        if(this.state == GET_SLICE){
            Log.Info("Adding found path to the current");
            // Not the way, but should work for testing
            this.PushTask(RailPathBuilder(this.path));

            local path = finder.GetPath();
            if(path.len() <=0){
                Log.Error("Failed to find path");
                return false;
            }

            local end = max(2, path.len() * 2 / 3) - 1;
            // If end points to the start of a bridge ramp move to the tile before
            if(Tile.GetDistanceManhattanToTile(path[end], path[end + 1]) > 1) end--;
            // If end points to the end of a bridge ramp move to the tile before the bridge
            if(Tile.GetDistanceManhattanToTile(path[end - 1], path[end]) > 1) end-=2;
            
            this.path = path.slice(0, end + 1);
            this.state = START_SEARCH;
            return true;
        }

        if(this.state == FINALIZE){
            Log.Warning("End of path is found");
            
            local end = this.path.len() - 1;

            // If end points to the end of a bridge ramp move to the tile before the bridge
            if(Tile.GetDistanceManhattanToTile(this.path[end - 1], this.path[end]) > 1) end-=2;

            // Not the way, but should work for testing
            this.PushTask(RailPathBuilder(this.path.slice(0, end + 1)));

            this.state = DONE;
            return true;
        }

        this.endDate = Date.GetCurrentDate();
        Log.Info("Extending path took " + (this.endDate - this.startDate) + " days");
        return false;
    }

    function AddEndPoints(distance, angle){
        // The start point into the end-zone, so we end the search 1/3 into the end-zone
        local endZone = this.size  * 5 / 3;
        if(distance < endZone) distance = endZone;

        // How wide does the arc needs to be
        local range = max(10, (100 - (distance / 2.0) + 0.5).tointeger());

        local endpoints = List();
        endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle, distance - this.size), 0);
        for(local i = 1; i < range; i+=1){
            endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle - i, distance - this.size), 0);
            endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle + i, distance - this.size), 0);
        }

        foreach(index, _ in endpoints){
            this.finder.AddEndPoint(index, 0);
        }
    }
}