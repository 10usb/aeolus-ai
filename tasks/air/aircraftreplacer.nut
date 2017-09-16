class AircraftReplacer extends Thread {
	static INITIALIZE = 0;
	static WAITING = 1;

	vehicle_id = 0;
	state = 0;
	stations = null;
	station_id = 0;
	cargo_id = null;
	capacity = 0;

	constructor(vehicle_id){
		this.vehicle_id = vehicle_id;
		this.state = INITIALIZE;
	}
}

function AircraftReplacer::GetName(){
	return "AircraftReplacer";
}

function AircraftReplacer::Run(){
	switch(state){
		case INITIALIZE: return Initialize();
		case WAITING: return Waiting();
		default:
			AILog.Error("Unknown state " + state);
		return false;
	}
}

function AircraftReplacer::Initialize(){
	stations = AIStationList_Vehicle(vehicle_id);
	if(stations.Count() <= 1){
		AILog.Warning("Need send this to depot, to get destroyed");
		return false;
	}

	local current = AIOrder.ResolveOrderPosition(vehicle_id, AIOrder.ORDER_CURRENT);
	while(!AIOrder.IsGotoStationOrder(vehicle_id, current)) {
	    current = (current + 1) % AIOrder.GetOrderCount(vehicle_id);
	}

	station_id = Station.GetStationID(AIOrder.GetOrderDestination(vehicle_id, current));

	if(Vehicle.HasSharedOrders(vehicle_id)){
		AIOrder.UnshareOrders(vehicle_id);
	}

	while(AIOrder.GetOrderCount(vehicle_id) > 0){
		AIOrder.RemoveOrder(vehicle_id, 0)
	}

	AIOrder.AppendOrder(vehicle_id, Station.GetLocation(station_id), AIOrder.OF_NO_LOAD);
	AIOrder.AppendOrder(vehicle_id, Station.GetLocation(station_id), AIOrder.OF_GOTO_NEAREST_DEPOT|AIOrder.OF_STOP_IN_DEPOT);

	local cargos = AICargoList();
	cargos.Valuate(AircraftReplacer.GetCapacity, vehicle_id);
	cargos.KeepAboveValue(0);
	cargos.Sort(AIList.SORT_BY_VALUE, false);
	cargo_id = cargos.Begin();
	capacity = cargos.GetValue(cargo_id);

	state = WAITING;
	return this.Sleep(50);
}

function AircraftReplacer::Waiting(){
	if(!Vehicle.IsStoppedInDepot(vehicle_id)){
		return this.Sleep(10);
	}
	Vehicle.SellVehicle(vehicle_id);

	local engines = Engine.GetForCargo(Vehicle.VT_AIR, cargo_id);
	engines.Valuate(Airport.CanEngineLand, Airport.GetAirportType(Station.GetLocation(station_id)));
	if(engines.Count() <= 0) return false;



	local cargoWaiting = Station.GetCargoWaiting(station_id, cargo_id);

	local destinations = [];

	foreach(destination_id, dummy in stations){
		destinations.push(Station.GetLocation(destination_id));
		cargoWaiting = Math.min(cargoWaiting, Station.GetCargoWaiting(destination_id, cargo_id));
	}

	local distance = 0;
	for(local index = 1; index < destinations.len(); index++){
		distance+= sqrt(AITile.GetDistanceSquareToTile(destinations[index - 1], destinations[index]));
	}
	distance+= sqrt(AITile.GetDistanceSquareToTile(destinations[0], destinations[destinations.len() - 1]));
	distance = distance.tointeger();

	local selected = AIList();
	foreach(engine_id, dummy in engines){
		local destinations = AIList();
		destinations.AddList(stations)
		destinations.Valuate(Airport.CanPlaneTypeLandOnStation, Engine.GetPlaneType(engine_id));
		destinations.KeepValue(1);
		if(destinations.Count() <= 0) continue;

		local days				= Engine.GetEstimatedDays(engine_id, distance, 0.95);

		local engine_capacity 	= ((Engine.GetCapacity(engine_id, cargo_id) * 1.12).tointeger() * 30 / days / 2);

		if((engine_capacity * 2) > cargoWaiting) continue;

		local income			= Cargo.GetCargoIncome(cargo_id, distance / stations.Count(), days) * engine_capacity;
		local running_cost		= AIEngine.GetRunningCost(engine_id) / 12;
		local profit			= income - running_cost;

		if(profit == 0){
			profit = -1;
		}

		local repay		= Engine.GetPrice(engine_id) / profit.tofloat();
		local remain	= (Engine.GetMaxAge(engine_id) * 12.0) - repay;

		local netto_profit = (remain * profit) / (Engine.GetMaxAge(engine_id) * 12.0);

		if(netto_profit > 0){
			selected.AddItem(engine_id, netto_profit.tointeger());
		}
	}

	if(selected.Count() <= 0){
		return false;
	}

	selected.Sort(AIList.SORT_BY_VALUE, false);
	local engine_id = selected.Begin();


	if(!Finance.GetMoney(Engine.GetPrice(engine_id))){
		return this.Wait(3);
	}

	stations.RemoveItem(station_id);


	vehicle_id = AIVehicle.BuildVehicle(Airport.GetHangarOfAirport(Station.GetLocation(station_id)), engine_id);
	if (!AIVehicle.IsValidVehicle(vehicle_id)){
		Finance.Repay();
		return false;
	}

	AILog.Info("Build replacement " + Engine.GetName(engine_id) + " at " + Station.GetName(station_id));
	AIVehicle.RefitVehicle(vehicle_id, cargo_id);

	AIOrder.AppendOrder(vehicle_id, Station.GetLocation(station_id), AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle_id, Station.GetLocation(station_id), AIOrder.OF_GOTO_NEAREST_DEPOT);

	foreach(destination_id, dummy in stations) {
		AIOrder.AppendOrder(vehicle_id, Station.GetLocation(destination_id), AIOrder.OF_NONE);
		AIOrder.AppendOrder(vehicle_id, Station.GetLocation(destination_id), AIOrder.OF_GOTO_NEAREST_DEPOT);
	}

	AIVehicle.StartStopVehicle(vehicle_id);

	Finance.Repay();


	return false;
}

function AircraftReplacer::GetCapacity(cargo_id, vehicle_id){
	return Vehicle.GetCapacity(vehicle_id, cargo_id);
}