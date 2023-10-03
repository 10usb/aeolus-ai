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

        local core = AITileList();
        core.AddRectangle(Tile.GetTranslatedIndex(this.center, -2, -2), Tile.GetTranslatedIndex(this.center, 2, 2));

        core.Valuate(Road.IsRoadTile);
        core.KeepValue(1);

        foreach(tile, _ in core){
            this.Enqueue(tile);
        }

        this.state = EXPLORE;
        return true;
    }

    function Enqueue(tile){
        this.queue.push(tile);
        this.explored.AddItem(tile, 0);
    }

    function Explore(){
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);

        local limit = 10;

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

        CheckNeighbor(tile, 1, 0);
        CheckNeighbor(tile, -1, 0);
        CheckNeighbor(tile, 0, 1);
        CheckNeighbor(tile, 0, -1);

        return true;
    }

    function CheckNeighbor(tile, deltaX, deltaY){
        local neighbor = Tile.GetTranslatedIndex(tile, deltaX, deltaY);
        
        // If it was already added to the queue once
        if(this.explored.HasItem(neighbor))
            return;

        // If it's within reasonable distance from the start
        if(Tile.GetDistanceManhattanToTile(neighbor, this.center) > this.distance)
            return false;

        if(this.CanFollow(tile, neighbor))
            this.Enqueue(neighbor);
    }

    function CanFollow(tile, neighbor){
        if(!Road.AreRoadTilesConnected(tile, neighbor))
            return false;
        
        this.signs.Build(tile, "F "+ Tile.GetCargoAcceptance(neighbor, this.cargo_id, 1, 1, 3));
        return Tile.GetCargoAcceptance(neighbor, this.cargo_id, 1, 1, 3) > 8;
    }
}