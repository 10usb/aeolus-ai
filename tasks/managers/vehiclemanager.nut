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
    replacer = null;

    function GetName(){
        return "Tasks_VehicleManager";
    }

    function Run(){
        local vehicles = AIVehicleList();
        if(vehicles.Count() <= 0){
            Log.Info("No vehicles to manage");
            return this.Wait(180);
        }

        // Vehicles to be selled are goners, so no need in tracking those
        vehicles.RemoveList(VehicleList_GroupName("to-be-selled"));

        local to_be_replaced = VehicleList_GroupName("to-be-replaced");
        // We don't need to caculate the age of vehicles in queue to being replaced
        vehicles.RemoveList(to_be_replaced);
        vehicles.Valuate(GetEffectiveAge);

        // For our average we add these with value 0 (no age)
        to_be_replaced.Valuate(Lists.SetValue, 0);
        vehicles.AddList(to_be_replaced);

        local average = Lists.GetAverage(vehicles);

        local temp = AIList();
        temp.AddList(vehicles);
        temp.Valuate(GetPrice);
        local total = Lists.GetSum(temp);

        temp.Valuate(GetSavings, total);
        local savings = Lists.GetSum(temp);

        local percentage = savings * 1000 / total;

        Log.Info("+ Average vehicle age: " + (average / 10.0) + "%");
        Log.Info("+ Savings needed: $ " + savings + " (" + (percentage / 10.0) + "%)");
        
        vehicles.RemoveList(to_be_replaced);

        if(average < 500){
            // Even though our avarage is below 50% there might be a vehicle
            // above 95% of age, these need to be replace no matter what.
            vehicles.RemoveBelow(950);

            if(vehicles.IsEmpty())
                return this.Wait(30);
        }
        
        vehicles.Sort(AIList.SORT_BY_VALUE, false);

        local vehicle_id = vehicles.Begin();

        local groups = GroupList_Name("to-be-replaced");
        groups.Valuate(AIGroup.GetVehicleType);
        groups.KeepValue(Vehicle.GetVehicleType(vehicle_id));
        if(groups.Count() <= 0)
            throw "Failed to get group";

        local group_id = groups.Begin();

        Log.Warning("Adding vehicle #" + vehicle_id + " to group #" + group_id + " (" + AIGroup.GetName(group_id) + ")");
        AIGroup.MoveVehicle(group_id, vehicle_id);

        if(replacer == null){
            replacer = Tasks_VehicleReplacer();
            this.GetParent().EnqueueTask(replacer);
        }else{
            replacer.WakeUp();
        }

        return this.Wait(10);
    }

    function GetEffectiveAge(vehicle_id){
        local maxAge = Vehicle.GetMaxAge(vehicle_id) * Engine.GetReliability(Vehicle.GetEngineType(vehicle_id)) / 100;

        return Vehicle.GetAge(vehicle_id) * 1000 / maxAge;
    }

    function GetSavings(vehicle_id, total){
        local engine_id = Vehicle.GetEngineType(vehicle_id);

        local maxAge = Vehicle.GetMaxAge(vehicle_id) * Engine.GetReliability(engine_id) / 100.0;

        // Age is percentage
        local age = Vehicle.GetAge(vehicle_id) / maxAge;
        if(age > 1)
            age = 1;

        // Get a curved percentage
        local curved = 1 - cos(asin(age));

        local price = Engine.GetPrice(engine_id);

        // How large is the share of this vehicle in the fleet
        local share = price * 2.0 / total;

        local percentage;
        if(share > 1){
            percentage = age;
        }else{
            // Use the liniare line weigted in share and curved for the rest
            percentage = (age * share) + (curved * (1 - share));    
        }

        // local fage = (age * 1000).tointeger() / 10.0;
        // local fcurved = (curved * 1000).tointeger() / 10.0;
        // local fshare = (share * 1000).tointeger() / 10.0;
        // local fpercentage = (percentage * 1000).tointeger() / 10.0;
        // Log.Info("age: " + fage + "; cos: " + fcurved + "; share: " + fshare + "; percentage: " + fpercentage);

        return (price * percentage).tointeger();
    }


    function GetPrice(vehicle_id){
        return Engine.GetPrice(Vehicle.GetEngineType(vehicle_id));
    }
}