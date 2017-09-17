
class AirStationManager extends Thread {
	static INITIALIZE		= 0;
	static NEXT_CARGO		= 1;
	static NEXT_ENGINE		= 2;
	static NEXT_STATION		= 3;
	static BUILD_AIRCRAFT	= 4;

	state = 0;

	station_id = 0;
	cargos = null;
	cargo_id = 0;
	engines = null;
	engine_id = 0;
	destinations = null
	destination_id = 0;

	selected = null;
	selected_profit = null;

	constructor(){
		this.state = INITIALIZE;
	}
}

function AirStationManager::GetName(){
	return "AirStationManager";
}

function AirStationManager::Run(){
	switch(state){
		case INITIALIZE: return Initialize();
		case NEXT_CARGO: return NextCargo();
		case NEXT_ENGINE: return NextEngine();
		case NEXT_STATION: return NextStation();
		case BUILD_AIRCRAFT: return BuildAircraft();
		default:
			AILog.Error("Unknown state " + state);
		return false;
	}
}

function AirStationManager::Initialize(){
	local stations = AIStationList(Station.STATION_AIRPORT);
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Valuate(Station.GetProperty, "air.station.manager.next_check_date", 0);
	stations.KeepBelowValue(AIDate.GetCurrentDate());
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Sort(AIList.SORT_BY_VALUE, true);

	station_id = stations.Begin();

	if(Airport.IsFull(station_id)){
		//AILog.Info(Station.GetName(station_id) + " is full");
		Station.SetProperty(station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + 90);
		return true;
	}


	cargos = AICargoList();
	cargos.Valuate(Cargo.GetAmountWaitingAtStation, station_id);
	cargos.KeepAboveValue(0);

	if(cargos.Count() <= 0){
		//AILog.Info("No cargo waiting at station " + Station.GetName(station_id));
		Station.SetProperty(station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + Airport.GetDaysBetweenAcceptPlane(Airport.GetAirportType(Station.GetLocation(station_id))));
		return true;
	}

	selected = [];
	selected_profit = AIList();

	state = NEXT_CARGO;
	return true;
}

function AirStationManager::NextCargo(){
	if(cargos.Count() <= 0){
		state = BUILD_AIRCRAFT;
		return true;
	}

	cargo_id = cargos.Begin();
	cargos.RemoveTop(1);
	
	//AILog.Info(Station.GetName(station_id) + " checking cargo" + Cargo.GetName(cargo_id));

	engines = Engine.GetForCargo(Vehicle.VT_AIR, cargo_id);
	engines.Valuate(Airport.CanEngineLand, Airport.GetAirportType(Station.GetLocation(station_id)));
	if(engines.Count() <= 0) return true;

	state = NEXT_ENGINE;
	return true;
}

function AirStationManager::NextEngine(){
	if(engines.Count() <= 0){
		state = NEXT_CARGO;
		return true;
	}

	engine_id = engines.Begin();
	engines.RemoveTop(1);

	//AILog.Info(Station.GetName(station_id) + " checking engine" + Engine.GetName(engine_id));

	destinations = AIStationList(Station.STATION_AIRPORT);
	destinations.RemoveItem(station_id);

	destinations.Valuate(Station.GetDistanceToTile, Station.GetLocation(station_id));
	destinations.KeepBetweenValue(Engine.GetEstimatedDistance(engine_id, 60, 0.95), Engine.GetEstimatedDistance(engine_id, 120, 0.95));
	if(destinations.Count() <= 0) return true;

	destinations.Valuate(Airport.CanPlaneTypeLandOnStation, Engine.GetPlaneType(engine_id));
	destinations.KeepValue(1);
	if(destinations.Count() <= 0) return true;

	destinations.Valuate(Airport.IsFull);
	destinations.KeepValue(0);
	if(destinations.Count() <= 0) return true;

	state = NEXT_STATION;
	return true;
}

function AirStationManager::NextStation(){
	if(destinations.Count() <= 0){
		state = NEXT_ENGINE;
		return true;
	}

	destination_id = destinations.Begin();
	destinations.RemoveTop(1);


	//AILog.InfoWarning(Station.GetName(station_id) + " checking engine" + Station.GetName(destination_id));

	local distance			= Station.GetDistanceToTile(station_id, Station.GetLocation(destination_id));
	local days				= Engine.GetEstimatedDays(engine_id, distance, 0.95);
	local engine_capacity 	= ((Engine.GetCapacity(engine_id, cargo_id) * 1.12).tointeger() * 30 / days / 2);

	if((engine_capacity * 2) > Math.min(Station.GetCargoWaiting(station_id, cargo_id), Station.GetCargoWaiting(destination_id, cargo_id))){
		return true;
	}

	local income			= Cargo.GetCargoIncome(cargo_id, distance, days) * engine_capacity;
	local running_cost		= Engine.GetRunningCost(engine_id) / 12;
	local profit			= income - running_cost;

	if(profit == 0){
		profit = -1;
	}

	local repay		= Engine.GetPrice(engine_id) / profit.tofloat();
	local remain	= (Engine.GetMaxAge(engine_id) * 12.0) - repay;

	local netto_profit = (remain * profit) / (Engine.GetMaxAge(engine_id) * 12.0);

	if(netto_profit > 0){
		selected_profit.AddItem(selected.len(), netto_profit.tointeger());
		selected.push({
			engine_id = engine_id,
			station_id = destination_id,
			cargo_id = cargo_id
		});
	}

	return true;
}

function AirStationManager::BuildAircraft(){
	if(selected_profit.Count() <= 0){
		//AILog.Info("No cargo waiting at station " + Station.GetName(station_id));
		Station.SetProperty(station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + Airport.GetDaysBetweenAcceptPlane(Airport.GetAirportType(Station.GetLocation(station_id))));
		return true;
	}

	selected_profit.Sort(AIList.SORT_BY_VALUE, false);
	local index = selected_profit.Begin();

	local price = Engine.GetPrice(selected[index].engine_id);
	local available = Finance.GetAvailableMoney();
	if(price > available){
		local days = Math.max(1, (price - available) * 30 / Finance.GetMonthlyProfit());
		return this.Wait(days);
	}

	if(!Finance.GetMoney(price)){
		AILog.Error("Failed to get enough money (" + price + " > " + available + ")");
		return this.Wait(3);
	}

	local source_tile = Station.GetLocation(station_id);
	local destination_tile = Station.GetLocation(selected[index].station_id);

	local vehicle_id = Vehicle.BuildVehicle(Airport.GetHangarOfAirport(source_tile), selected[index].engine_id);
	if (!Vehicle.IsValidVehicle(vehicle_id)){
		AILog.Error("Failed to build extra " + Engine.GetName(selected[index].engine_id) + " at " + Station.GetName(station_id));
		Finance.Repay();Station.SetProperty(station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + 10);
		state = INITIALIZE;
		return true;
	}

	AILog.Info("Build extra " + Engine.GetName(selected[index].engine_id) + " at " + Station.GetName(station_id));
	Vehicle.RefitVehicle(vehicle_id, selected[index].cargo_id);

	AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
	AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
	Vehicle.StartStopVehicle(vehicle_id);

	Finance.Repay();

	Station.SetProperty(station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + Airport.GetDaysBetweenAcceptPlane(Airport.GetAirportType(Station.GetLocation(station_id))));
	Station.SetProperty(selected[index].station_id, "air.station.manager.next_check_date", AIDate.GetCurrentDate() + Airport.GetDaysBetweenAcceptPlane(Airport.GetAirportType(Station.GetLocation(selected[index].station_id))));

	state = INITIALIZE;
	return true;
}