/**
 * This task must be initialized with a path of at least 2 tile and it will
 * build a track to its destination. It does this with search steps of the
 * specified size. It only builds 2/3 of each step to ensure that the joint of
 * each step is smoothed out. It stops building at the same distance from the
 * destination. It returns the tile index of its terminal.
 */
class RailPathExtender extends Task {
    path = null;
    destination = null;
    size = null;
    finder = null;
    state = 0;
    steps = 0;

	constructor(path, destination, size){
        local end = max(2, path.len() * 2 / 3);
        this.path = path.slice(0, end);
        this.destination = destination;
        this.size = size;
    }

    function GetName(){
        return "RailPathExtender";
    }
    
    function Run(){
        if(state == 0){
            Log.Info("Starting search for extending path");
            this.finder = RailPathFinder();
            // this.finder.debug = true;
            this.finder.AddStartPoint(this.path[this.path.len() - 1], this.path[this.path.len() - 2], 0);
            state++;
            return true;
        }

        if(state == 1){
            Log.Info("Add the endpoints to the finder");
            local origin = this.path[this.path.len() - 1];
            local distance = Tile.GetDistance(origin, this.destination);

            // Because we only build 2/3 of the path we're going to search 1/3
            // further into the end-zone (7/9 = 2.333/3 to make a marginal difference)
            if(distance < (this.size  * 7 / 9)){
                Log.Warning("End of path is found");
                // Not the way, but should work for testing
                this.GetParent().EnqueueTask(RailPathBuilder(this.path));
                state = 5;
                return false;
            }else{
                Log.Info("Remaining distance " + distance);
            }

            this.AddEndPoints(distance, Tile.GetAngle(this.destination, origin));
            state++;
            return true;
        }
    
        if(this.state == 2){
            Log.Info("Initialize finder");
            this.finder.Init();
            this.steps = 0;
            this.state++;
            return true;
        }

        if(this.state == 3){
            this.finder.BeginStep();
            local limit = 35;
            while(limit-- > 0 && this.steps++ < 50000){
                if(!this.finder.Step()){
                    this.state++;
                    return true;
                }
            }
    
            return true;
        }
    
        if(this.state == 4){
            Log.Info("Adding found path to the current");
            // Not the way, but should work for testing
            this.GetParent().EnqueueTask(RailPathBuilder(this.path));

            local path = finder.GetPath();
            if(path.len() <=0){
                Log.Error("Failed to find path");
                return false;
            }

            local end = max(2, path.len() * 2 / 3);
            this.path = path.slice(0, end);
            this.state = 0;
            return true;
        }

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