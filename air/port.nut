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