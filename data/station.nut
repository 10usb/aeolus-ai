class Station extends AIStation {
}

function Station::GetProperty(station_id, key, defaultValue){
	local list = Storage.ValueExists("stations") ? Storage.GetValue("stations") : Storage.SetValue("stations", {});
	if(!list.rawin(station_id)) return defaultValue;

	local station  = list.rawget(station_id);
	if(!station.rawin(key)) return defaultValue;
	return station.rawget(key);
}

function Station::SetProperty(station_id, key, value){
	local list = Storage.ValueExists("stations") ? Storage.GetValue("stations") : Storage.SetValue("stations", {});
	if(!list.rawin(station_id)) list.rawset(station_id, {});
	list.rawget(station_id).rawset(key, value);
}

function Station::GetAiportMaintenanceCostFactor(station_id){
	return Airport.GetMaintenanceCostFactor(Airport.GetAirportType(Station.GetLocation(station_id)));
}

function Station::GetDistanceToTile(station_id, tile){
	return sqrt(Station.GetDistanceSquareToTile(station_id, tile)).tointeger();
}

function Station::GetDaysTravel(station_id, tile, speed){
	return (Math.sqrt(Station.GetDistanceSquareToTile(station_id, tile)) * 44.3 / speed).tointeger();
}
