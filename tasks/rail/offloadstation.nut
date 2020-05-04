/**
 * This task will find the best spot for a offload station around a destination
 * industry with a path connected to a path terminal
 */
 class RailOffloadStation extends Task {
    destination_id = null;
    terminal = null;
    length = null;
    state = 0;
    startDate = null;
    endDate = null;

    tiles = null;
    bounds = null;

    stationHp = null;
    stationHn = null;
    stationVp = null;
    stationVn = null;

    best = null;

    constructor(destination_id, terminal, length){
        this.destination_id = destination_id;
        this.terminal = terminal;
        this.length = length;
        this.best = null;
    }

    function GetName(){
        return "RailOffloadStation";
    }
    
    function Run(){
        switch(this.state){
            case 0: return LoadMeta();
            case 1: return StartSearch();
            case 2: return SelectBest();
        }
        
        if(this.best){
            Log.Info("Finding of best offload station for " + Industry.GetName(this.destination_id) + " took " + (this.endDate - this.startDate) + " days with a value of " + this.best.finder.GetBest());
        }else{
            Log.Info("Failed to find offload station for " + Industry.GetName(this.destination_id) + " wasted " + (this.endDate - this.startDate) + " days");
        }
        return false;
    }
    
    function LoadMeta(){
        this.startDate = Date.GetCurrentDate();
        local radius = Station.GetCoverageRadius(Station.STATION_TRAIN);
        local destination = Industry.GetLocation(this.destination_id);

        local industry_type = Industry.GetIndustryType(this.destination_id);
        local cargos = IndustryType.GetAcceptedCargo(industry_type);

        Log.Info("Radius of station: " + radius);
        Log.Info("Industry type: " + IndustryType.GetName(industry_type));

        foreach(cargo_id, dummy in cargos){
            Log.Info(" - " + Cargo.GetName(cargo_id));
        }

        // Get a list of tiles in range
        this.tiles = AITileList_IndustryAccepting(destination_id, radius);
        
        // Get X1
        this.tiles.Valuate(Tile.GetX);
        this.tiles.Sort(List.SORT_BY_VALUE, List.SORT_ASCENDING);
        local x1 = tiles.GetValue(tiles.Begin());
        
        // Get X2
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_DESCENDING);
        local x2 = tiles.GetValue(tiles.Begin());

        // Get Y1
        tiles.Valuate(Tile.GetY);
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_ASCENDING);
        local y1 = tiles.GetValue(tiles.Begin());

        // Get Y2
        tiles.Sort(List.SORT_BY_VALUE, List.SORT_DESCENDING);
        local y2 = tiles.GetValue(tiles.Begin());

        this.bounds = {
            x1 = x1,
            y1 = y1,
            x2 = x2,
            y2 = y2
        };

        this.state++;
        return true;
    }
    
    function StartSearch(){
        local endpoints = List();
        endpoints.AddItem(this.terminal, 0);

        local queue = TaskQueue();

        local horizontal = AITileList();
        horizontal.AddRectangle(Tile.GetIndex(this.bounds.x1 - (this.length - 1), this.bounds.y2), Tile.GetIndex(this.bounds.x1 - 1, this.bounds.y1));
        horizontal.AddList(tiles);
        
        horizontal.Valuate(Tile.IsBuildableRectangle, this.length, 1);
        horizontal.KeepValue(1);

        horizontal.Valuate(Tile.IsFlatRectangle, this.length, 1);
        horizontal.KeepValue(1);

        this.stationHp = RailFindStation(horizontal, this.length, 0, endpoints);
        // this.stationHp.debug = true;
        queue.EnqueueTask(this.stationHp);

        this.stationHn = RailFindStation(horizontal, -1, 0, endpoints);
        // this.stationHn.debug = true;
        queue.EnqueueTask(this.stationHn);


        local vertical = AITileList();
        vertical.AddRectangle(Tile.GetIndex(this.bounds.x2, this.bounds.y1 - (this.length - 1)), Tile.GetIndex(this.bounds.x1, this.bounds.y1 - 1));
        vertical.AddList(this.tiles);

        vertical.Valuate(Tile.IsBuildableRectangle, 1, this.length);
        vertical.KeepValue(1);

        vertical.Valuate(Tile.IsFlatRectangle, 1, this.length);
        vertical.KeepValue(1);

        this.stationVp = RailFindStation(vertical, 0, this.length, endpoints);
        // this.stationVp.debug = true;
        queue.EnqueueTask(this.stationVp);

        this.stationVn = RailFindStation(vertical, 0, -1, endpoints);
        // this.stationVn.debug = true;
        queue.EnqueueTask(this.stationVn);

        this.PushTask(queue);

        this.state++;
        return true;
    }

    function IsBetter(previous, value){
        if(value < 0) return false;
        if(previous < 0) return true;
        return previous > value;
    }

    function SelectBest(){
        local value = -1;

        if(IsBetter(value, this.stationHp.finder.GetBest())){
            this.best = this.stationHp;
            value = this.stationHp.finder.GetBest();
        }
        if(IsBetter(value, this.stationHn.finder.GetBest())){
            this.best = this.stationHn;
            value = this.stationHn.finder.GetBest();
        }
        if(IsBetter(value, this.stationVp.finder.GetBest())){
            this.best = this.stationVp;
            value = this.stationVp.finder.GetBest();
        }
        if(IsBetter(value, this.stationVn.finder.GetBest())){
            this.best = this.stationVn;
            value = this.stationVn.finder.GetBest();
        }

        this.endDate = Date.GetCurrentDate();

        this.state++;
        return true;
    }
}