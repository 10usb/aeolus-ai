/**
* The task of this tracer is follow the roads of a town to generate
* a list of tiles that if a stattion is places accepts or produces
* a given cargo. It's not bound to the roads the given town has authority
* over instead all tiles that are within a given distance.
*/
class Tasks_Road_TownTracer extends Task {
    static INIT      	= 0;
    static EXPLORE      = 1;
    static FINALIZE     = 2;
    
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
        return "Tasks_Road_TownTracer";
    }

    function Run(){
        switch(state){
            case INIT: return Init();
            case EXPLORE: return Explore();
            case FINALIZE: return Finalize();
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

    function Explore(){
        Road.SetCurrentRoadType(Road.ROADTYPE_ROAD);

        // We can do around 200 steps in 10 ticks
        local limit = 200;

        while(limit--){
            if(!Step()){
                this.state = FINALIZE;
                return true;
            }
        }

        return true;
    }

    function Finalize(){
        Log.Error("== Done ==");

        local stations = AIList();
        stations.AddList(this.matches);
        stations.Valuate(Tile.IsBuildable);
        stations.KeepValue(0);
        stations.Valuate(Tile.GetCargoAcceptance, this.cargo_id, 1, 1, 3);
        stations.RemoveBelowValue(40);

        foreach(tile, accept in stations){
            this.signs.Build(tile, "" + accept);
        }

        local depots = AIList();
        depots.AddList(this.matches);
        depots.Valuate(Tile.IsBuildable);
        depots.KeepValue(1);

        foreach(tile, _ in depots){
            this.signs.Build(tile, "DEPOT");
        }

        return false;
    }

    function Enqueue(tile){
        this.queue.push(tile);
        this.explored.AddItem(tile, 0);
    }

    function Step(){
        if(!queue.len()) return false;

        local tile =  queue[0];
        queue.remove(0);

        local flat = Tile.IsFlat(tile);
        if(flat){
            local tracks = Road.GetRoadTracks(tile);
            if(tracks == Rail.RAILTRACK_NE_SW || tracks == Rail.RAILTRACK_NW_SE){
                this.matches.AddItem(tile, Tile.GetCargoAcceptance(tile, this.cargo_id, 1, 1, 3));
            }
        }

        CheckNeighbor(tile, 1, 0, flat);
        CheckNeighbor(tile, -1, 0, flat);
        CheckNeighbor(tile, 0, 1, flat);
        CheckNeighbor(tile, 0, -1, flat);

        return true;
    }

    function CheckNeighbor(tile, deltaX, deltaY, flat){
        local neighbor = Tile.GetTranslatedIndex(tile, deltaX, deltaY);
        
        // If it was already added to the queue once
        if(this.explored.HasItem(neighbor))
            return;

        // If it's within reasonable distance from the start
        if(Tile.GetDistanceManhattanToTile(neighbor, this.center) > this.distance)
            return false;

        if(flat && Tile.IsFlat(neighbor) && Tile.IsBuildable(neighbor)){
            this.matches.AddItem(neighbor, Tile.GetCargoAcceptance(neighbor, this.cargo_id, 1, 1, 3));
        }

        if(this.CanFollow(tile, neighbor))
            this.Enqueue(neighbor);
        
        if(AIBridge.IsBridgeTile(neighbor)){
            local end = AIBridge.GetOtherBridgeEnd(neighbor);
            
            this.explored.AddItem(neighbor, 0);
            this.explored.AddItem(end, 0);

            local vector = MapVector.Create(neighbor, end);
            local length = vector.Length();

            vector.Normalize();
            local endpoint = vector.GetTileIndex(length + 1);
    
            if(Road.AreRoadTilesConnected(end, endpoint))
                this.Enqueue(endpoint);
        }
    }

    function CanFollow(tile, neighbor){
        if(!Road.AreRoadTilesConnected(tile, neighbor))
            return false;
        
        if(AIBridge.IsBridgeTile(neighbor))
            return false;
        
        return Tile.GetCargoAcceptance(neighbor, this.cargo_id, 1, 1, 3) > 8;
    }
}