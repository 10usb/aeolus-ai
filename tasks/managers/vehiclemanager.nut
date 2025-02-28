/**
* The task of the fleet mananger is to look after the vehicles. It's main task is to
* replace vehicles that are getting old and are in need of replacement.
* 
* To avoid waves of replacements that bring highcosts with them, it should keep the 
* average age around 50%. By doing this the costs for replacement is spread out over
* time.
* 
* The second task of the fleet manager is to keep track of the efficiency of a vehicle.
* It should do this by looking at it's orders and approximate its optimal travel time.
* Them keep track of its actual traveltime.
*/
class Tasks_VehicleManager extends Task {
    static INIT      	= 0;
    
    state = 0;
    
    constructor(){
        state = INIT;
    }

    function GetName(){
        return "Tasks_VehicleManager";
    }

    function Run(){
        switch(state){
            case INIT: return Init();
        }

        return false;
    }

    function Init(){
        local vehicles = AIVehicleList();
        if(vehicles.Count() <= 0)
            return this.Wait(180);

        local to_be_replaced = VehicleList_GroupName("to-be-replaced");
        // We don't need to caculate the age of vehicles in queue to
        // being replaced
        vehicles.RemoveList(to_be_replaced);
        vehicles.Valuate(GetEffectiveAge);

        // Log.Warning("Vehicle age");
        // foreach(vehicle_id, age in vehicles){
        //     Log.Info(vehicle_id + " => " + age);
        // }

        // For our average we add these with value 0 (no age)
        to_be_replaced.Valuate(Lists.SetValue, 0);
        vehicles.AddList(to_be_replaced);

        local average = Lists.GetAverage(vehicles);
        Log.Info("+ Average vehicle age: " + (average / 10.0) + "%");

        if(average < 500)
            return this.Wait(30);

        vehicles.RemoveList(to_be_replaced);
        vehicles.Sort(AIList.SORT_BY_VALUE, false);

        local vehicle_id = vehicles.Begin();
        // send vehicle_id to depot to sell
        Log.Warning("TODO send vehicle #" + vehicle_id + " (" + Vehicle.GetName(vehicle_id) + ") to be replaced");

        return this.Wait(10);
    }

    function GetEffectiveAge(vehicle_id){
        local maxAge = Vehicle.GetMaxAge(vehicle_id) * Engine.GetReliability(Vehicle.GetEngineType(vehicle_id)) / 100;

        return Vehicle.GetAge(vehicle_id) * 1000 / maxAge;
    }
}