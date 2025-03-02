/**
 *
 */
class Tasks_VehicleReplacer extends Task {
    static PERFORM_CHECK = 0;
    static MAKE_REPLACEMENT = 1;
    
    state = 0;
    vehicle_id = null;
    engine_id = null;
    depot_tile = null;
    
    constructor(){
        state = PERFORM_CHECK;
    }

    function GetName(){
        return "Tasks_VehicleReplacer";
    }

    function Run(){
        switch(state){
            case PERFORM_CHECK: return Check();
            case MAKE_REPLACEMENT: return MakeReplacement();
        }

        return false;
    }

    function Check(){
        local to_be_selled = VehicleList_GroupName("to-be-selled");
        to_be_selled.Valuate(Vehicle.IsStoppedInDepot);
        
        foreach(vehicle_id, _ in to_be_selled)
	        Vehicle.SellVehicle(vehicle_id);

        local to_be_replaced = VehicleList_GroupName("to-be-replaced");

        if(!to_be_replaced.IsEmpty()){
            this.vehicle_id = to_be_replaced.Begin();
            this.state = MAKE_REPLACEMENT;
            return true;
        }

        if(!to_be_selled.IsEmpty())
            return this.Wait(5);

        return this.Wait(180);
    }

    function MakeReplacement(){
        // - Get list of cargo vehicle is transporting
        local cargos = AICargoList();
        cargos.Valuate(Vehicle.GetCargoCapacity, this.vehicle_id);
        cargos.RemoveValue(0);

        Log.Warning("Cargo capacity");
        foreach(cargo_id, value in cargos){
            Log.Info(" - " + Cargo.GetName(cargo_id) + " => " + value);
        }

        // - Find best engine that fits to match route
        local engines = Engine.GetForCargo(Vehicle.GetVehicleType(this.vehicle_id), cargos.Begin());
        Log.Warning("Possible engines");
        foreach(engine_id, value in engines){
            Log.Info(" - " + Engine.GetName(engine_id) + " => " + value);
        }
        this.engine_id = engines.Begin();

        // - Find depot closest/connected to first order
        local depots = AIDepotList(Vehicle.ToTransportType(Vehicle.GetVehicleType(this.vehicle_id)));
        depots.Valuate(Tile.GetManhattanDistance, AIOrder.GetOrderDestination(this.vehicle_id, 0));
        depots.Sort(List.SORT_BY_VALUE, false);
        
        // TODO except for AIR test if depot and destination are connected by road, rail or water
        this.depot_tile = depots.Begin();

        // - Create replacement and copy orders
        local cost = Engine.GetPrice(this.engine_id) * 1.2;
        if(!Budget.Take(Company.GetInvestmentBudget(), cost)){
            Budget.Request(Company.GetInvestmentBudget(), cost);
            Log.Warning("Waiting for money ENGINE");
            return this.Wait(3);
        }

        local new_vehicle_id = Vehicle.BuildVehicle(this.depot_tile, this.engine_id);
        AIOrder.CopyOrders(new_vehicle_id, this.vehicle_id);
        Vehicle.StartStopVehicle(new_vehicle_id);

        // - Move vehicle to the sell list
        local groups = GroupList_Name("to-be-selled");
        groups.Valuate(AIGroup.GetVehicleType);
        groups.KeepValue(Vehicle.GetVehicleType(this.vehicle_id));
        if(groups.Count() <= 0)
            throw "Failed to get group";

        local group_id = groups.Begin();

        Log.Warning("Moving vehicle #" + this.vehicle_id + " to group #" + group_id + " (" + AIGroup.GetName(group_id) + ")");
        AIGroup.MoveVehicle(group_id, this.vehicle_id);

        // - Alter orders so its stops as nearest depot
        Vehicle.SendVehicleToDepot(this.vehicle_id);

        this.state = PERFORM_CHECK;
        return true;
    }
}