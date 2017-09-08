class AirPort {
}

function AirPort::IsSmall(station_id){
	switch(AIAirport.GetAirportType(AIStation.GetLocation(station_id))){
		case AIAirport.AT_COMMUTER: return true;
		case AIAirport.AT_SMALL: return true;
	}
	return false;
}
function AirPort::IsLarge(station_id){
	switch(AIAirport.GetAirportType(AIStation.GetLocation(station_id))){
		case AIAirport.AT_LARGE: return true;
		case AIAirport.AT_METROPOLITAN: return true;
		case AIAirport.AT_INTERNATIONAL: return true;
		case AIAirport.AT_INTERCON: return true;
	}
	return false;
}
function AirPort::IsHeliport(station_id){
	switch(AIAirport.GetAirportType(AIStation.GetLocation(station_id))){
		case AIAirport.AT_HELIPORT: return true;
		case AIAirport.AT_HELISTATION: return true;
	}
	return false;
}

function AirPort::GetBestType(small){
	if(small){
		foreach(type in [AIAirport.AT_COMMUTER, AIAirport.AT_SMALL]){
			if(AIAirport.IsValidAirportType(type)){
				return type;
			}
		}
		throw("Did not found any falid airport types");
	}
	foreach(type in [AIAirport.AT_INTERCON, AIAirport.AT_INTERNATIONAL, AIAirport.AT_METROPOLITAN, AIAirport.AT_LARGE, AIAirport.AT_COMMUTER, AIAirport.AT_SMALL]){
		if(AIAirport.IsValidAirportType(type)){
			return type;
		}
	}
	throw("Did not found any falid airport types");
}

function AirPort::GetTypes(){
	local list = AIList();
	list.AddItem(AIAirport.AT_SMALL, 0);
	list.AddItem(AIAirport.AT_LARGE, 0);
	list.AddItem(AIAirport.AT_METROPOLITAN, 0);
	list.AddItem(AIAirport.AT_INTERNATIONAL, 0);
	list.AddItem(AIAirport.AT_COMMUTER, 0);
	list.AddItem(AIAirport.AT_INTERCON, 0);
	list.AddItem(AIAirport.AT_HELIPORT, 0);
	list.AddItem(AIAirport.AT_HELISTATION, 0);
	list.AddItem(AIAirport.AT_HELIDEPOT, 0);
	return list;
}

function AirPort::GetTypeName(type){
	switch(type){
		case AIAirport.AT_SMALL: return "Small";
		case AIAirport.AT_LARGE: return "Large";
		case AIAirport.AT_METROPOLITAN: return "Metropolitan";
		case AIAirport.AT_INTERNATIONAL: return "International";
		case AIAirport.AT_COMMUTER: return "Commuter";
		case AIAirport.AT_INTERCON: return "Intercon";
		case AIAirport.AT_HELIPORT: return "Heliport";
		case AIAirport.AT_HELISTATION: return "Helistation";
		case AIAirport.AT_HELIDEPOT: return "Helidepot";
	}
	throw("Unknown aiport tyoe");
}

function AirPort::GetDaysBetweenAcceptPlane(type){
	switch(type){
		case AIAirport.AT_SMALL: return 18;
		case AIAirport.AT_LARGE: return 10;
		case AIAirport.AT_METROPOLITAN: return 6;
		case AIAirport.AT_INTERNATIONAL: return 4;
		case AIAirport.AT_COMMUTER: return 10;
		case AIAirport.AT_INTERCON: return 2;
		case AIAirport.AT_HELIPORT: return 24;
		case AIAirport.AT_HELISTATION: return 18;
		case AIAirport.AT_HELIDEPOT: return 18;
	}
	throw("Unknown aiport tyoe");
}