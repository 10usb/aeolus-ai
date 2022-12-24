/**
 * This task only tries to connect busses and post-trucks
 * within the border of a city
 */
 class Road_BuildVehicle extends Task {
    engine_id = null;
    depot_tile = null;
    station = null;
    destinations = [];
    budget_id = null;

	constructor(engine_id, depot_tile, station, destinations, budget_id){
        this.engine_id = engine_id;
        this.depot_tile = depot_tile;
        this.station = station;
        this.destinations = destinations;
        this.budget_id = budget_id;
	}

    function GetName(){
        return "Road_InnerCity";
    }

    function Run(){
        local cost = Engine.GetPrice(engine_id) * 1.2;
        if(!Budget.Take(budget_id, cost)){
            Budget.Request(budget_id, cost);
            Log.Warning("Waiting for money ENGINE");
            return this.Wait(3);
        }

        Log.Info("Building vehicle");
        local vehicle_id = Vehicle.BuildVehicle(depot_tile, engine_id);
        AIOrder.AppendOrder(vehicle_id, station, AIOrder.OF_NON_STOP_INTERMEDIATE);

        destinations.Valuate(Lists.RandRangeItem, 0, 1000);
        destinations.Sort(List.SORT_BY_VALUE, false);
        destinations.KeepTop(2);

        foreach(destination, _ in destinations){
            AIOrder.AppendOrder(vehicle_id, destination, AIOrder.OF_NON_STOP_INTERMEDIATE);
        }
        AIOrder.AppendOrder(vehicle_id, depot_tile, AIOrder.OF_GOTO_NEAREST_DEPOT|AIOrder.OF_NON_STOP_INTERMEDIATE);
        AIVehicle.StartStopVehicle(vehicle_id);
    }
}