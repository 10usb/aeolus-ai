
class AircraftManager extends Task {
}

function AircraftManager::GetName(){
	return "AircraftManager";
}

function AircraftManager::Run(){
	local vehicles = AIVehicleList();
	if(vehicles.Count() <= 0) return this.Wait(180);

	vehicles.Valuate(Vehicle.GetVehicleType);
	vehicles.KeepValue(Vehicle.VT_AIR);
	if(vehicles.Count() <= 0) return this.Wait(90);

	vehicles.Valuate(Vehicle.GetProperty, "air.manager.next_check_date", 0);

	vehicles.KeepBelowValue(AIDate.GetCurrentDate());
	if(vehicles.Count() <= 0) return this.Wait(10);

	vehicles.Sort(AIList.SORT_BY_VALUE, true);
	local vehicle_id = vehicles.Begin();

	if(Vehicle.GetAgePercentage(vehicle_id) > 70){
		Vehicle.SetProperty(vehicle_id, "air.manager.next_check_date", AIDate.GetCurrentDate() + 180);
		Aeolus.AddThread(AircraftReplacer(vehicle_id));
		return true;
	}

	Vehicle.SetProperty(vehicle_id, "air.manager.next_check_date", AIDate.GetCurrentDate() + 10);
	return true;
}