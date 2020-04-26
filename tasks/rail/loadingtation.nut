/**
 * This task will find the best spot for a loading station around a source
 * industry with an initial path pointing to a destination tile
 */
 class RailLoadingStation extends Task {
    source_id = null;
    destination = null;
    length = null;
    size = null;
    state = null;

    startDate = null;
    endDate = null;

    tiles = null;
    bounds = null;
    endpoints = null;

    stationHp = null;
    stationHn = null;
    stationVp = null;
    stationVn = null;

    best = null;

	constructor(source_id, destination, length, size){
        this.source_id = source_id;
        this.destination = destination;
        this.length = length;
        this.size = size;
        this.state = 0;
    }

    function GetName(){
        return "RailLoadingStation";
    }
    
    function Run(){
        switch(this.state){
            case 0: return LoadMeta();
            case 1: return EndPoints();
            case 2: return StartSearch();
            case 3: return SelectBest();
        }
        
        // Log.Info("Best: " + this.best.finder.GetBest() + " dir: " + this.best.offset.x + "," + this.best.offset.y + " steps: " + this.best.steps);
        Log.Info("Finding of best loading station for " + Industry.GetName(source_id) + " took " + (this.endDate - this.startDate) + " days with a value of " + this.best.finder.GetBest());
        return false;
    }
    
    function LoadMeta(){
        this.startDate = Date.GetCurrentDate();
        local radius = Station.GetCoverageRadius(Station.STATION_TRAIN);
        local length = 4;
        local origin = Industry.GetLocation(source_id);
        local industry_type = Industry.GetIndustryType(source_id);
        local cargos = IndustryType.GetProducedCargo(industry_type);

        Log.Info("Radius of station: " + radius);
        Log.Info("Industry type: " + IndustryType.GetName(industry_type));
        Log.Info("Industry raw: " + IndustryType.IsRawIndustry(industry_type));

        foreach(cargo_id, dummy in cargos){
            Log.Info(" - " + Cargo.GetName(cargo_id));
        }

        // Get a list of tiles in range
        this.tiles = AITileList_IndustryProducing(source_id, radius);
        
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

    function EndPoints(){
        local origin = Industry.GetLocation(this.source_id);
        local distance = Tile.GetDistance(origin, this.destination);
        local angle = Tile.GetAngle(this.destination, origin);
        local endZone = this.size  * 5 / 3;

        if(distance < endZone) distance = endZone;

        // How wide does the arc needs to be
        local range = max(10, (100 - (distance / 2.0) + 0.5).tointeger());
        
        this.endpoints = List();
        this.endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle, distance - this.size), 0);
        for(local i = 1; i < range; i+=1){
            this.endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle - i, distance - this.size), 0);
            this.endpoints.AddItem(Tile.GetAngledIndex(this.destination, angle + i, distance - this.size), 0);
        }
        
        this.state++;
        return true;
    }
    
    function StartSearch(){
        local queue = TaskQueue();

        local horizontal = AITileList();
        horizontal.AddRectangle(Tile.GetIndex(this.bounds.x1 - (this.length - 1), this.bounds.y2), Tile.GetIndex(this.bounds.x1 - 1, this.bounds.y1));
        horizontal.AddList(tiles);
        
        horizontal.Valuate(Tile.IsBuildableRectangle, this.length, 1);
        horizontal.KeepValue(1);

        horizontal.Valuate(Tile.IsFlatRectangle, this.length, 1);
        horizontal.KeepValue(1);

        this.stationHp = RailFindStation(horizontal, this.length, 0, this.endpoints);
        queue.EnqueueTask(this.stationHp);

        this.stationHn = RailFindStation(horizontal, -1, 0, this.endpoints);
        queue.EnqueueTask(this.stationHn);


        local vertical = AITileList();
        vertical.AddRectangle(Tile.GetIndex(this.bounds.x2, this.bounds.y1 - (this.length - 1)), Tile.GetIndex(this.bounds.x1, this.bounds.y1 - 1));
        vertical.AddList(this.tiles);

        vertical.Valuate(Tile.IsBuildableRectangle, 1, this.length);
        vertical.KeepValue(1);

        vertical.Valuate(Tile.IsFlatRectangle, 1, this.length);
        vertical.KeepValue(1);

        this.stationVp = RailFindStation(vertical, 0, this.length, this.endpoints);
        queue.EnqueueTask(this.stationVp);

        this.stationVn = RailFindStation(vertical, 0, -1, this.endpoints);
        queue.EnqueueTask(this.stationVn);

        this.PushTask(queue);

        this.state++;
        return true;
    }

    function SelectBest(){
        this.best = this.stationHp;
        local value = this.stationHp.finder.GetBest();

        if(value > this.stationHn.finder.GetBest()){
            this.best = this.stationHn;
            value = this.stationHn.finder.GetBest();
        }
        if(value > this.stationVp.finder.GetBest()){
            this.best = this.stationVp;
            value = this.stationVp.finder.GetBest();
        }
        if(value > this.stationVn.finder.GetBest()){
            this.best = this.stationVn;
            value = this.stationVn.finder.GetBest();
        }

        this.endDate = Date.GetCurrentDate();

        this.state++;
        return true;
    }
}