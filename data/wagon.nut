class Wagon {
	constructor(){
	}
}

function Wagon::GetFor(cargo_id, rail_type){
	local wagons = AIEngineList(AIVehicle.VT_RAIL);
	wagons.Valuate(AIEngine.IsBuildable);
	wagons.KeepValue(1);
	wagons.Valuate(AIEngine.IsWagon);
	wagons.KeepValue(1);
	wagons.Valuate(AIEngine.GetCargoType);
	wagons.KeepValue(cargo_id);
	wagons.Valuate(AIEngine.GetRailType);
	wagons.KeepValue(rail_type);
	return wagons.Begin();
}

function Wagon::GetFullWeight(wagon_id, cargo_id) {
	return AIEngine.GetWeight(wagon_id) + Cargo.GetWeight(cargo_id, AIEngine.GetCapacity(wagon_id));
}