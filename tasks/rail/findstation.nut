/**
 * This task will performs a path search to find the most obtimal station
 * location for each tile a station can be build on.
 */
class RailFindStation extends Task {
    tiles = null;
    offset = null;
    endpoints = null;
    finder = null;
    state = null;
    steps = null;
    debug = false;

	constructor(tiles, ox, oy, endpoints){
        this.tiles = tiles;
        this.offset = {
            x = ox,
            y = oy
        };
        this.endpoints = endpoints;
        this.state = 0;
        this.steps = 0;
	}

    function GetName(){
        return "RailFindStation"
    }

    function Run(){
        if(this.state == 0){
            this.finder = RailPathFinder();
            this.finder.debug = this.debug;

            foreach(index, _ in this.tiles){
                local start = Tile.GetTranslatedIndex(index, this.offset.x, this.offset.y);
                // is the terminal of the station is not builable the trains can't leave the station
                if(!Tile.IsBuildable(start)) continue;

                local towards = index;
                if(this.offset.x > 0){
                    towards = Tile.GetTranslatedIndex(index, this.offset.x - 1, this.offset.y);
                }else if(this.offset.y > 0){
                    towards = Tile.GetTranslatedIndex(index, this.offset.x, this.offset.y - 1);
                }
                this.finder.AddStartPoint(start, towards, 0);
            }
            this.state++;
            return true;
        }
        
        if(this.state == 1){
            foreach(index, _ in this.endpoints){
                this.finder.AddEndPoint(index, 0);
            }
            this.state++;
            return true;
        }
        
        if(this.state == 2){
            this.finder.Init();
            this.state++;
            return true;
        }
        
        if(this.state == 3){
            this.finder.BeginStep();
            local limit = 35;
            while(limit-- > 0 && this.steps++ < 50000){
                if(!this.finder.Step()){
                    this.state++;

                    Log.Info("dir: " + this.offset.x + "," + this.offset.y + " steps: " + this.steps);
                    Log.Info("Value: " + finder.GetBest());
                    return false;
                }
            }

            return true;
        }
    }
}