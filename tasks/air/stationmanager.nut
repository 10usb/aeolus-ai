
class AirStationManager extends Thread {
}

function AirStationManager::GetName(){
	return "AirStationManager";
}

function AirStationManager::Run(){
	local stations = AIStationList(Station.STATION_AIRPORT);
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Valuate(Station.GetProperty, "air.station.manager.check_date", 0);
	stations.KeepBelowValue(AIDate.GetCurrentDate() - 10);
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Sort(AIList.SORT_BY_VALUE, true);

	local station_id = stations.Begin();

	if(Airport.IsFull(station_id)){
		//AILog.Info(Station.GetName(station_id) + " is full");
		Station.SetProperty(station_id, "air.station.manager.check_date", AIDate.GetCurrentDate());
		return true;
	}


	local cargos = AICargoList();
	cargos.Valuate(Cargo.GetAmountWaitingAtStation, station_id);
	cargos.KeepAboveValue(0);

	local selected = [];
	local selected_profit = AIList();

	foreach(cargo_id, amount in cargos){
		//AILog.Info(Cargo.GetName(cargo_id) + " (" + amount + ")");

		local engines = Engine.GetForCargo(Vehicle.VT_AIR, cargo_id);
		engines.Valuate(Airport.CanEngineLand, Airport.GetAirportType(Station.GetLocation(station_id)));
		//engines.Valuate(Engine.GetEstimatedIncomeByDays, cargo_id, 100, 0.95);
		//engines.Sort(AIList.SORT_BY_VALUE, false);
		if(engines.Count() <= 0) continue;

		foreach(engine_id, value in engines){
			local stations = AIStationList(Station.STATION_AIRPORT);
			stations.RemoveItem(station_id);

			stations.Valuate(Station.GetDistanceToTile, Station.GetLocation(station_id));
			stations.KeepBetweenValue(Engine.GetEstimatedDistance(engine_id, 60, 0.95), Engine.GetEstimatedDistance(engine_id, 120, 0.95));
			if(stations.Count() <= 0) continue;

			stations.Valuate(Airport.CanPlaneTypeLandOnStation, Engine.GetPlaneType(engine_id));
			stations.KeepValue(1);
			if(stations.Count() <= 0) continue;

			stations.Valuate(Airport.IsFull);
			stations.KeepValue(0);
			if(stations.Count() <= 0) continue;

			foreach(destination_id, dummy in stations){
				local distance			= Station.GetDistanceToTile(station_id, Station.GetLocation(destination_id));

				local days				= Engine.GetEstimatedDays(engine_id, distance, 0.95);

				local engine_capacity 	= ((Engine.GetCapacity(engine_id, cargo_id) * 1.12).tointeger() * 30 / days / 2);

				if((engine_capacity * 2) > Math.min(Station.GetCargoWaiting(station_id, cargo_id), Station.GetCargoWaiting(destination_id, cargo_id))) continue;

				local income			= Cargo.GetCargoIncome(cargo_id, distance, days) * engine_capacity;
				local running_cost		= AIEngine.GetRunningCost(engine_id) / 12;
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
			}
		}
	}

	if(selected_profit.Count() <= 0){
		Station.SetProperty(station_id, "air.station.manager.check_date", AIDate.GetCurrentDate());
		return true;
	}

	selected_profit.Sort(AIList.SORT_BY_VALUE, false);
	local index = selected_profit.Begin();

	if(!Finance.GetMoney(Engine.GetPrice(selected[index].engine_id))){
		//AILog.Info("Waiting for enough money");
		return this.Sleep(100);
	}

	local source_tile = Station.GetLocation(station_id);
	local destination_tile = Station.GetLocation(selected[index].station_id);

	local vehicle_id = AIVehicle.BuildVehicle(Airport.GetHangarOfAirport(source_tile), selected[index].engine_id);
	if (!AIVehicle.IsValidVehicle(vehicle_id)){
		Finance.Repay();
		Station.SetProperty(station_id, "air.station.manager.check_date", AIDate.GetCurrentDate());
		return true;
	}

	AILog.Info("Build extra " + Engine.GetName(selected[index].engine_id) + " at " + Station.GetName(station_id));
	AIVehicle.RefitVehicle(vehicle_id, selected[index].cargo_id);

	AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
	AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
	AIVehicle.StartStopVehicle(vehicle_id);

	Finance.Repay();

	Station.SetProperty(station_id, "air.station.manager.check_date", AIDate.GetCurrentDate() + 10);
	Station.SetProperty(selected[index].station_id, "air.station.manager.check_date", AIDate.GetCurrentDate());
	return true;
}