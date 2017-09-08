
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

function Airport::GetDaysBetweenAcceptPlane(type){
	switch(type){
		case Airport.AT_SMALL: return 20;
		case Airport.AT_LARGE: return 12;
		case Airport.AT_METROPOLITAN: return 7;
		case Airport.AT_INTERNATIONAL: return 4;
		case Airport.AT_COMMUTER: return 12;
		case Airport.AT_INTERCON: return 3;
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
