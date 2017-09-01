class Engine {
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
	temp.Valuate(AIEngine.CanRefitCargo, cargo_id);
	temp.KeepValue(1);
	possibilities.AddList(temp);

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.CanPullCargo, cargo_id);
	temp.KeepValue(1);
	possibilities.AddList(temp);

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