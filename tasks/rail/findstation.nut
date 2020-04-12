class RailFindStation extends Task {
    tiles = null;
    offset = null;
    length = null;
    endpoints = null;
    finder = null;
    state = null;
    steps = null;

	constructor(tiles, ox, oy, length, endpoints){
        this.tiles = tiles;
        this.offset = {
            x = ox,
            y = oy
        };
        this.length = length;
        this.endpoints = endpoints;
        this.state = 0;
        this.steps = 0;
	}
}

function RailFindStation::GetName(){
    return "RailFindStation"
}

function RailFindStation::Run(){
    if(this.state == 0){
        this.finder = RailPathFinder();

        foreach(towards, _ in this.tiles){
            local index = Tile.GetTranslatedIndex(towards, this.offset.x, this.offset.y);
            this.finder.AddStartPoint(index, towards, 0);
        }
        
        foreach(index, _ in this.endpoints){
            this.finder.AddEndPoint(index, 0);
        }
        this.state++;
        return true;
    }
    
    if(this.state == 1){
        this.finder.Init();
        this.state++;
        return true;
    }
    
    if(this.state == 2){
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