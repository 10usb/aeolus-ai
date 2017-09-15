class Vehicle extends AIVehicle {

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