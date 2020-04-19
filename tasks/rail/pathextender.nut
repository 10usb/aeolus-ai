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
        return "RailPathExtender"
    }
    
    function Run(){
        if(state == 0){
            this.finder = RailPathFinder();
            //this.finder.debug = true;
            this.finder.AddStartPoint(this.path[path.len() - 1], this.path[path.len() - 2], 0);
            state++;
            return true;
        }

        if(state == 1){
            this.AddEndPoints();
            state++;
            return true;
        }
    
        if(this.state == 2){
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
            // Not the way, but should work for testing
            this.GetParent().EnqueueTask(RailPathBuilder(this.path));

            local path = finder.GetPath();
            if(path.len() <=0){
                Log.Error("Failed to find path")
                return false;
            }

            local end = max(2, path.len() * 2 / 3);
            this.path = path.slice(0, end);
            this.state = 0;
            return true;
        }

        return false;
    }

    function AddEndPoints(){
        local origin = this.path[path.len() - 1];
        local end = destination;

        local distance = Tile.GetDistance(origin, end);

        local angle = Tile.GetAngle(end, origin);
        local endpoints = List();
        local range = max(10, (100 - (distance / 2.0) + 0.5).tointeger());

        if(distance < 35) distance = 35;

        for(local j = this.size; j <= this.size + 2; j++){
            endpoints.AddItem(Tile.GetAngledIndex(end, angle, distance - j), 0);
            for(local i = 1; i < range; i+=1){
                endpoints.AddItem(Tile.GetAngledIndex(end, angle - i, distance - j), 0);
                endpoints.AddItem(Tile.GetAngledIndex(end, angle + i, distance - j), 0);
            }
        }

        foreach(index, _ in endpoints){
            this.finder.AddEndPoint(index, 0);
        }
    }
}