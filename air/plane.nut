class AirPlane {
}

function AirPlane::IsSmall(engine_id){
	return AIEngine.GetPlaneType(engine_id)==AIAirport.PT_SMALL_PLANE;
}

function AirPlane::IsOld(vehicle_id){
	return (AIVehicle.GetAge(vehicle_id) * 100.0 / AIVehicle.GetMaxAge(vehicle_id)) > 70;
}

function AirPlane::FindBestPlane(){
	local engine_id = AirPlane.FindBigPlane();
	
	if(engine_id == null){
		engine_id = AirPlane.FindSmallPlane();
	}
	
	return engine_id;
}

function AirPlane::FindBigPlane(){
	local engine_id = null;
	local engine_value = 0;
	
	if(AIAirport.IsValidAirportType(AIAirport.AT_LARGE)){
		foreach(id, dummy in AIEngineList(AIVehicle.VT_AIR)){
			if(AIEngine.GetPlaneType(id)==AIAirport.PT_BIG_PLANE){
				local value = (AIEngine.GetMaxSpeed(id) * AIEngine.GetCapacity(id) * 1.0) / AIEngine.GetRunningCost(id);
				
				if(value > engine_value){
					engine_value = value;
					engine_id = id;
				}
			}
		}
	}
	
	return engine_id;
}

function AirPlane::FindSmallPlane(){
	local engine_id = null;
	local engine_value = 0;
	
	foreach(id, dummy in AIEngineList(AIVehicle.VT_AIR)){
		if(AIEngine.GetPlaneType(id)==AIAirport.PT_SMALL_PLANE){
			local value = (AIEngine.GetMaxSpeed(id) * AIEngine.GetCapacity(id) * 1.0) / AIEngine.GetRunningCost(id);
			
			if(value > engine_value){
				engine_value = value;
				engine_id = id;
			}
		}
	}
	
	return engine_id;
}