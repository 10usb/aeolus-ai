class Vehicle extends AIVehicle {
}

function Vehicle::GetProperty(vehicle_id, key, defaultValue){
	local list = Storage.ValueExists("vehicles") ? Storage.GetValue("vehicles") : Storage.SetValue("vehicles", {});
	if(!list.rawin(vehicle_id)) return defaultValue;

	local station  = list.rawget(vehicle_id);
	if(!station.rawin(key)) return defaultValue;
	return station.rawget(key);
}

function Vehicle::SetProperty(vehicle_id, key, value){
	local list = Storage.ValueExists("vehicles") ? Storage.GetValue("vehicles") : Storage.SetValue("vehicles", {});
	if(!list.rawin(vehicle_id)) list.rawset(vehicle_id, {});
	list.rawget(vehicle_id).rawset(key, value);
}

function Vehicle::GetOrderDistance(vehicle_id){
	local destinations = [];

	for(local index = 0; index < AIOrder.GetOrderCount(vehicle_id); index++){
		if(AIOrder.IsGotoStationOrder(vehicle_id, index) || AIOrder.IsGotoWaypointOrder(vehicle_id, index)){
			destinations.push(AIOrder.GetOrderDestination(vehicle_id, index));
		}
	}
	if(destinations.len() <= 1) return 0;

	local distance = 0;

	for(local index = 1; index < destinations.len(); index++){
		distance+= sqrt(AITile.GetDistanceSquareToTile(destinations[index - 1], destinations[index]));
	}
	distance+= sqrt(AITile.GetDistanceSquareToTile(destinations[0], destinations[destinations.len() - 1]));

	return distance;
}

function Vehicle::GetEstimatedDaysTravel(vehicle_id, efficiency){
	return Engine.GetEstimatedDays(Vehicle.GetEngineType(vehicle_id), Vehicle.GetOrderDistance(vehicle_id), efficiency);
}

function Vehicle::GetAgePercentage(vehicle_id){
	return (AIVehicle.GetAge(vehicle_id) * 100.0 / AIVehicle.GetMaxAge(vehicle_id)).tointeger();
}

function Vehicle::GetTypes(){
	return [
		Vehicle.VT_RAIL,
		Vehicle.VT_ROAD,
		Vehicle.VT_WATER,
		Vehicle.VT_AIR
	];
}