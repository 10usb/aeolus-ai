
class AirAircraftManager extends Thread {
	static CHECK = 0;
	static REPLACE = 1;

	state = 0;
	vehicle_id = 0;

	constructor(){
		this.state = CHECK;
	}
}

function AirAircraftManager::GetName(){
	return "Air.AircraftManager";
}

function AirAircraftManager::Run(){
	switch(state){
		case CHECK: return Check();
		default:
			AILog.Error("Unknown state " + state);
		return false;
	}
}

function AirAircraftManager::Check(){
	local vehicles = AIVehicleList();
	if(vehicles.Count() <= 0) return this.Sleep(50);

	vehicles.Valuate(Vehicle.GetVehicleType);
	vehicles.KeepValue(Vehicle.VT_AIR);
	if(vehicles.Count() <= 0) return this.Sleep(50);

	vehicles.Valuate(Vehicle.GetProperty, "air.manager.next_check_date", 0);

	vehicles.KeepBelowValue(AIDate.GetCurrentDate());
	if(vehicles.Count() <= 0) return this.Sleep(50);

	vehicles.Sort(AIList.SORT_BY_VALUE, true);
	vehicle_id = stations.Begin();

	if(Vehicle.GetAgePercentage(vehicle_id) > 70){
		state = REPLACE;
		return true;
	}

	local old = AIList();
	old.AddList(vehicles);
	old.Valuate(Vehicle.GetAgePercentage);
	old.KeepAboveValue(70);
	foreach(vehicle_id, age in old){
		if(!AIOrder.IsGotoDepotOrder(vehicle_id, AIOrder.ORDER_CURRENT)) {
			AIVehicle.SendVehicleToDepot(vehicle_id);
		}
	}

	local indepot = AIList();
	indepot.AddList(vehicles);
	indepot.Valuate(AIVehicle.IsStoppedInDepot);
	indepot.KeepValue(1);

	foreach(vehicle_id, dummy in indepot){
		AIVehicle.SellVehicle(vehicle_id);
	}
	return this.Wait(50);
}