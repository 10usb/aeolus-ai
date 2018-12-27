class Airport extends AIAirport {
}

function Airport::GetList(){
	local list = AIList();
	list.AddItem(Airport.AT_SMALL, 0);
	list.AddItem(Airport.AT_LARGE, 0);
	list.AddItem(Airport.AT_METROPOLITAN, 0);
	list.AddItem(Airport.AT_INTERNATIONAL, 0);
	list.AddItem(Airport.AT_COMMUTER, 0);
	list.AddItem(Airport.AT_INTERCON, 0);
	list.AddItem(Airport.AT_HELIPORT, 0);
	list.AddItem(Airport.AT_HELISTATION, 0);
	list.AddItem(Airport.AT_HELIDEPOT, 0);
	return list;
}

function Airport::GetName(type){
	switch(type){
		case Airport.AT_SMALL: return "Small";
		case Airport.AT_LARGE: return "Large";
		case Airport.AT_METROPOLITAN: return "Metropolitan";
		case Airport.AT_INTERNATIONAL: return "International";
		case Airport.AT_COMMUTER: return "Commuter";
		case Airport.AT_INTERCON: return "Intercon";
		case Airport.AT_HELIPORT: return "Heliport";
		case Airport.AT_HELISTATION: return "Helistation";
		case Airport.AT_HELIDEPOT: return "Helidepot";
	}
	throw("Unknown AirportType");
}

function Airport::GetPlaneTypeName(type){
	switch(type){
		case Airport.PT_SMALL_PLANE: return "Small plane";
		case Airport.PT_BIG_PLANE: return "Big plane";
		case Airport.PT_HELICOPTER: return "Helicopter";
	}
	throw("Unknown AirportType");
}

function Airport::GetDaysBetweenAcceptPlane(type){
	switch(type){
		case Airport.AT_SMALL: return 19;
		case Airport.AT_LARGE: return 14;
		case Airport.AT_METROPOLITAN: return 10;
		case Airport.AT_INTERNATIONAL: return 8;
		case Airport.AT_COMMUTER: return 14;
		case Airport.AT_INTERCON: return 6;
		case Airport.AT_HELIPORT: return 24;
		case Airport.AT_HELISTATION: return 20;
		case Airport.AT_HELIDEPOT: return 20;
	}
	throw("Unknown AirportType");
}

function Airport::GetMaintenanceAmount(){
	local stations = AIStationList(Station.STATION_AIRPORT);

	if(stations.Count() <= 0) return 500;

	stations.Valuate(Station.GetAiportMaintenanceCostFactor);
	return AIInfrastructure.GetMonthlyInfrastructureCosts(Company.COMPANY_SELF, AIInfrastructure.INFRASTRUCTURE_AIRPORT) / List.GetSum(stations);
}

function Airport::GetMaintenanceCost(type){
	return Airport.GetMaintenanceCostFactor(type) * Airport.GetMaintenanceAmount();
}

function Airport::CanPlaneTypeLand(type, plane_type){
	switch(plane_type){
		case Airport.PT_HELICOPTER: return 1;
		case Airport.PT_SMALL_PLANE:
			switch(type){
				case Airport.AT_SMALL:
				case Airport.AT_LARGE:
				case Airport.AT_METROPOLITAN:
				case Airport.AT_INTERNATIONAL:
				case Airport.AT_COMMUTER:
				case Airport.AT_INTERCON:
				return 1;
			}
		break;
		case Airport.PT_BIG_PLANE:
			switch(type){
				case Airport.AT_LARGE:
				case Airport.AT_METROPOLITAN:
				case Airport.AT_INTERNATIONAL:
				case Airport.AT_INTERCON:
				return 1;
			}
		break;
	}
	return 0;
}

function Airport::CanEngineLand(engine_id, type){
	return Airport.CanPlaneTypeLand(type, Engine.GetPlaneType(engine_id));
}

function Airport::CanPlaneTypeLandOnStation(station_id, plane_type){
	return Airport.CanPlaneTypeLand(Airport.GetAirportType(Station.GetLocation(station_id)), plane_type);
}

function Airport::IsFull(station_id){
	local vehicles = AIVehicleList_Station(station_id);
	if(vehicles.Count() <= 0) return 0;
	vehicles.Valuate(Vehicle.GetVehicleType);
	vehicles.KeepValue(Vehicle.VT_AIR);
	vehicles.Valuate(Vehicle.GetEstimatedDaysTravel, 0.95);
	local days = List.GetAvg(vehicles);
	local airportType = Airport.GetAirportType(Station.GetLocation(station_id));

	if(vehicles.Count() < ceil(days.tofloat() / Airport.GetDaysBetweenAcceptPlane(airportType))){
		return 0;
	}
	return 1;
}