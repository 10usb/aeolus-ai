/**
* The task of this tracer is follow the roads of a town to generate
* a list of tiles that if a stattion is places accepts or produces
* a given cargo. It's not bound to the roads the given town has authority
* over instead all tiles that are within a given distance.
*/
class Tasks_Road_TownTracer extends Task {
    static INIT      	= 0;
    static EXPLORE      = 1;
    
    state = 0;
    town_id = null;
    cargo_id = null;
    distance = null;
    signs = null;
    center = null;
    queue = null;
    explored = null;
    matches = null;
    
    constructor(town_id, cargo_id, distance){
        this.town_id = town_id;
        this.cargo_id = cargo_id;
        this.distance = distance;

        this.state = INIT;
    }

    function GetName(){
        return "Tasks_Road_TownTracer"
    }

    function Run(){
        switch(state){
            case INIT: return Init();
            case EXPLORE: return Explore();
        }

        return false;
    }

    function Init(){
        this.signs = Signs();
        this.center = Town.GetLocation(this.town_id);
        this.queue = [];

        this.explored = AIList();
        this.matches = AIList();

        
        this.Enqueue(this.center);

        this.state = EXPLORE;
        return true;
    }

    function Enqueue(tile){
        this.queue.push(tile);
        this.explored.AddItem(tile, 0);
    }

    function Explore(){
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);

        local limit = 5;

        while(limit--){
            if(!Step()){
                Log.Error("== Done ==");
                return false;
            }
        }

        return true;
    }

    function Step(){
        if(!queue.len()) return false;

        local tile =  queue[0];
        queue.remove(0);

        if(Road.IsRoadTile(tile)){
            this.Follow(tile);
        }else if(Tile.GetDistanceManhattanToTile(tile, this.center) < 2){
            this.Find(tile);
        }

        return true;
    }

    function Find(tile){
        this.signs.Build(tile, "E");

        local test = null;
        test = Tile.GetTranslatedIndex(tile, 1, 0);
        if(!this.explored.HasItem(test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, -1, 0);
        if(!this.explored.HasItem(test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, 0, 1);
        if(!this.explored.HasItem(test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, 0, -1);
        if(!this.explored.HasItem(test))
            this.Enqueue(test);
    }

    function Follow(tile){
        local test = null;
        test = Tile.GetTranslatedIndex(tile, 1, 0);
        if(this.CanFollow(tile, test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, -1, 0);
        if(this.CanFollow(tile, test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, 0, 1);
        if(this.CanFollow(tile, test))
            this.Enqueue(test);

        test = Tile.GetTranslatedIndex(tile, 0, -1);
        if(this.CanFollow(tile, test))
            this.Enqueue(test);
    }

    function CanFollow(tile, test){
        if(this.explored.HasItem(test))
            return false;

        if(Tile.GetDistanceManhattanToTile(test, this.center) > this.distance)
            return false;
        
        if(!Road.AreRoadTilesConnected(tile, test))
            return false;
        
        this.signs.Build(tile, "F "+ Tile.GetCargoAcceptance(test, this.cargo_id, 1, 1, 3));
        return Tile.GetCargoAcceptance(test, this.cargo_id, 1, 1, 3) > 8;
    }
}