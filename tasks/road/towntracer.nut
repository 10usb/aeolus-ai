/**
* The task of this tracer is to follow the roads of a town to generate
* a list of tiles that if a station is placed accepts or produces
* a given cargo. 
* 
* It's not bound to the roads the given town has authority, instead all
* tiles that are within a given acceptable distance
*/
class Tasks_Road_TownTracer extends Task {
    static INIT      	= 0;
    static EXPLORE      = 1;
    static FINALIZE     = 2;
    
    state = 0;
    town_id = null;
    cargo_id = null;
    distance = null;
    debug = null;

    signs = null;
    center = null;
    queue = null;
    explored = null;
    matches = null;
    stations = null;
    depots = null;
    empties = null;
    selected = null;
    
    constructor(town_id, cargo_id, distance, debug = false){
        this.town_id = town_id;
        this.cargo_id = cargo_id;
        this.distance = distance;
        this.debug = debug;

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
        this.stations = AIList();
        this.depots = AIList();
        this.empties = AIList();

        local core = AITileList();
        core.AddRectangle(Tile.GetTranslatedIndex(this.center, -2, -2), Tile.GetTranslatedIndex(this.center, 2, 2));
        core.Valuate(Road.IsRoadTile);
        core.KeepValue(1);

        if(core.IsEmpty()){
            Log.Error("No start in this town");
            return false;
        }

        // Select a junction is posible
        core.Valuate(Road.GetNeighbourRoadCount);
        core.Sort(List.SORT_BY_VALUE, false);
        this.queue.push(core.Begin());

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
                return false;
            }
        }

        return true;
    }

    function Finalize(){
        return false;
    }

    function Step(){
        if(!queue.len())
            return false;

        local tile = queue[0];
        queue.remove(0);

        local flat = Tile.IsFlat(tile);
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

        this.explored.AddItem(neighbor, 0);
        
        if(this.debug) this.signs.Build(neighbor, "#");

        // If it's within reasonable distance from the start
        if(Tile.GetDistanceManhattanToTile(neighbor, this.center) > this.distance)
            return;

        // To follow it, it must be connected
        if(!Road.AreRoadTilesConnected(tile, neighbor)){
            if(this.debug) this.signs.Remove(neighbor);

            if(flat && Tile.IsFlat(neighbor) && Tile.IsBuildable(neighbor)){
                this.empties.AddItem(neighbor, Tile.GetCargoAcceptance(neighbor, this.cargo_id, 1, 1, 3));
            }
            return;
        }
        
        local next = neighbor;
        
        if(AIBridge.IsBridgeTile(neighbor)){
            local end = AIBridge.GetOtherBridgeEnd(neighbor);
            this.explored.AddItem(end, 0);

            local vector = MapVector.Create(neighbor, end);
            local length = vector.Length();

            vector.Normalize();
            next = vector.GetTileIndex(length + 1);
    
            if(!Road.AreRoadTilesConnected(end, next))
                return;

            this.explored.AddItem(next, 0);
        }else if(AITunnel.IsTunnelTile(neighbor)){
            local end = AITunnel.GetOtherTunnelEnd(neighbor);
            
            this.explored.AddItem(neighbor, 0);
            this.explored.AddItem(end, 0);

            local vector = MapVector.Create(neighbor, end);
            local length = vector.Length();

            vector.Normalize();
            next = vector.GetTileIndex(length + 1);
    
            if(!Road.AreRoadTilesConnected(end, next))
                return;

            this.explored.AddItem(next, 0);
        }

        // Any drive through station is passable but not buildable
        if(Road.IsDriveThroughRoadStationTile(next)){
            this.queue.push(next);
            this.stations.AddItem(next, 0);

            if(this.debug){
                if(Tile.GetOwner(next) == AICompany.ResolveCompanyID(AICompany.COMPANY_SELF)){
                    this.signs.Build(next, "SELF");
                }else{
                    this.signs.Build(next, "OTHER");
                }
            }

            return;
        }

        // These are seen as roads but dead-ends
        if(Road.IsRoadDepotTile(next)){
            this.depots.AddItem(next, 0);

            if(this.debug){
                if(Tile.GetOwner(next) == AICompany.ResolveCompanyID(AICompany.COMPANY_SELF)){
                    this.signs.Build(next, "SELF");
                }else{
                    this.signs.Build(next, "OTHER");
                }
            }
            return;
        }

        // These are seen as roads but dead-ends
        if(Road.IsRoadStationTile(next)){
            // TODO add to some list?
            if(this.debug) this.signs.Build(next, "X");
            return;
        }

        this.Enqueue(next);
    }

    function Enqueue(tile){
        // Make sure we only follow roads that have enough acceptance of the cargo
        // otherwise we can't sell the product
        local acceptance = Tile.GetCargoAcceptance(tile, this.cargo_id, 1, 1, 3);
        //local production = Tile.GetCargoProduction(tile, this.cargo_id, 1, 1, 3);

        if(this.debug) this.signs.Build(tile, acceptance);

        if(acceptance < 6)
            return;

        // When the road is flat
        local flat = Tile.IsFlat(tile);
        if(flat && Road.GetNeighbourRoadCount(tile) <= 2){
            local tracks = Road.GetRoadTracks(tile);
            if(tracks == Rail.RAILTRACK_NE_SW || tracks == Rail.RAILTRACK_NW_SE)
                this.matches.AddItem(tile, 0);
        }else{
            if(this.debug) this.signs.Remove(tile);
        }

        this.queue.push(tile);
    }
}