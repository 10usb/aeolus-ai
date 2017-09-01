class Station {
	static list = {};
	
	id = null;
	
	constructor(id){
		this.id = id;
	}
}

function Station::Get(id){
	if(!Station.rawin(id)){
		Station.list.rawset(id, Station(id));
	}
	return Station.list[id];
}

function Station::GetIsFull(station_id){
	local list = AIVehicleList_Station(station_id);
	return list.Count() > 4;
}

function Station::GetDaysTravel(station_id, tile, speed){
	return (Math.sqrt(AIStation.GetDistanceSquareToTile(station_id, tile)) * 44.3 / speed).tointeger();
}
function Station::IsFull(){
	local list = AIVehicleList_Station(this.id);
	return list.Count() > 4;
}