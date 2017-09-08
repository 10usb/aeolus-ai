class Station extends AIStation {
	static list = {};
}


function Station::GetIsFull(station_id){
	local list = AIVehicleList_Station(station_id);
	return list.Count() > 4;
}

function Station::GetDaysTravel(station_id, tile, speed){
	return (Math.sqrt(Station.GetDistanceSquareToTile(station_id, tile)) * 44.3 / speed).tointeger();
}

function Station::GetAiportMaintenanceCostFactor(station_id){
	return Aiport.GetMaintenanceCostFactor(Station.GetAirportType(Station.GetLocation(station_id)));
}