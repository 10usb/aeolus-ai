class Engine extends AIEngine {
	constructor(){
	}
}

function Engine::GetForCargo(vehicle_type, cargo_id){
	local engines = AIEngineList(vehicle_type);
	engines.Valuate(AIEngine.IsBuildable);
	engines.KeepValue(1);

	if(vehicle_type == AIVehicle.VT_RAIL){
		engines.Valuate(AIEngine.IsWagon);
		engines.KeepValue(0);
	}

	local possibilities = AIList();

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.GetCargoType);
	temp.KeepValue(cargo_id);
	possibilities.AddList(temp);

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.CanPullCargo, cargo_id);
	temp.KeepValue(1);
	possibilities.AddList(temp);

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.CanRefitCargo, cargo_id);
	temp.KeepValue(1);

	if(vehicle_type == AIVehicle.VT_RAIL && AICargo.IsFreight(cargo_id)){
		possibilities.RemoveList(temp);
	}else{
		possibilities.AddList(temp);
	}


	possibilities.Sort(AIList.SORT_BY_ITEM, true);

	return possibilities;
}

function Engine::GetWagonLength(engine_id, cargo_id, max_distance = 0){
	local wagon_id		= Wagon.GetFor(cargo_id, AIEngine.GetRailType(engine_id));
	local wagon_weight	= Wagon.GetFullWeight(wagon_id, cargo_id);
	local length = 9;

	while(length > 0){
		local acceleration = AIEngine.GetPower(engine_id) * 1.0 / (AIEngine.GetWeight(engine_id) + wagon_weight * length);


		local distance = 0;
		local speed = 0;
		while (speed < AIEngine.GetMaxSpeed(engine_id)) {
			speed+= acceleration;
			distance+= speed;
		}

		if( (distance / 230) < (max_distance > 0 ? max_distance : Math.min(sqrt(AIEngine.GetMaxSpeed(engine_id)), AIEngine.GetMaxSpeed(engine_id) / 10)) ) break;
		length--;
	}

	return length;
}

function Engine::GetEstimatedDistance(engine_id, days, efficiency){
	return (AIEngine.GetMaxSpeed(engine_id) * efficiency * days / 33.2).tointeger();
}

function Engine::GetEstimatedDays(engine_id, distance, efficiency){
	return (distance * 33.2 / efficiency / AIEngine.GetMaxSpeed(engine_id)).tointeger();
}

function Engine::GetCapacity(engine_id, cargo_id, length = 0, wagon_id = -1){
	local capacity = 0;
	if(AIEngine.CanRefitCargo(engine_id, cargo_id)){
		capacity+= AIEngine.GetCapacity(engine_id);
	}
	if(AIEngine.CanPullCargo(engine_id, cargo_id)){
		if(wagon_id < 0){
			wagon_id = Wagon.GetFor(cargo_id, AIEngine.GetRailType(engine_id));
			if(wagon_id < 0){
				AILog.Error("No wagon selected");
			}
		}

		if(length <= 0){
			length = Engine.GetWagonLength(engine_id, cargo_id);
		}
		capacity+= AIEngine.GetCapacity(wagon_id) * length;
	}

	return capacity;
}

function Engine::GetEstimatedIncomeByDays(engine_id, cargo_id, days, efficiency, length = 0, wagon_id = -1){
	if(efficiency <= 0){
		if(Engine.GetVehicleType() == AIVehicle.VT_AIR){
			efficiency = 0.95;
		}else{
			efficiency = 0.45;
		}
	}
	local capacity		= Engine.GetCapacity(engine_id, cargo_id, length, wagon_id);
	local cargoPrice	= AICargo.GetCargoIncome(cargo_id, Engine.GetEstimatedDistance(engine_id, days, efficiency), days);
	local cost			= AIEngine.GetRunningCost(engine_id) / 365.0 * days;
	return ((capacity * cargoPrice) - cost).tointeger();
}

function Engine::GetEstimatedProfitByDistance(engine_id, cargo_id, distance, efficiency, length = 0, wagon_id = -1){
	local days			= Engine.GetEstimatedDays(engine_id, distance, efficiency);
	local capacity		= Engine.GetCapacity(engine_id, cargo_id, length, wagon_id);
	local cargoPrice	= AICargo.GetCargoIncome(cargo_id, distance, days);
	local cost			= AIEngine.GetRunningCost(engine_id) / 365.0 * days;
	return ((capacity * cargoPrice) - cost).tointeger();
}