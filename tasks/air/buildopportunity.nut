
class AirBuildOpportunity extends Thread {
	opportunity_id = null;
	state = 0;
	success_state = 0;
	failed_state = 0;
	airport_type = 0;
	width = 0;
	height = 0;
	budget = 0;
	town_id = 0;
	list = null;
	tile = 0;
	engine_id = 0;
	cargo_id = 0;
	needed_planes = 0;

	source_tile = 0;
	destination_tile = 0;
	budget_id = 0;

	constructor(opportunity_id){
		this.opportunity_id = opportunity_id;
		this.state = 0;
		this.budget_id = Budget.Create(Opportunity.GetMinimumPrice(opportunity_id));
	}
}

function AirBuildOpportunity::GetName(){
	return "AirBuildOpportunity";
}

function AirBuildOpportunity::Run(){
	switch(state){
		case 0:
			airport_type = Opportunity.GetAirportType(opportunity_id);
			width = Airport.GetAirportWidth(airport_type);
			height = Airport.GetAirportHeight(airport_type);

			AILog.Info("Building " + Opportunity.GetSourceName(opportunity_id) + " <==> " + Opportunity.GetDestinationName(opportunity_id) + " with " + Cargo.GetName(Opportunity.GetCargo(opportunity_id)));
			AILog.Info("  price     : " + Opportunity.GetPrice(opportunity_id));
			AILog.Info("  min. price: " + Opportunity.GetMinimumPrice(opportunity_id));
			AILog.Info("  profit    : " + Opportunity.GetMonthlyProfit(opportunity_id));
			AILog.Info("  months    : " + ceil(Opportunity.GetPrice(opportunity_id).tofloat() / Opportunity.GetMonthlyProfit(opportunity_id)));
			AILog.Info("  airport   : " + Airport.GetName(airport_type));
			AILog.Info("  engine    : " + Engine.GetName(Opportunity.GetEngine(opportunity_id)));

			state++;
		return true;
		case 1: return BuildSource();
		case 2: return BuildAirport();
		case 3: return TryBuildAirport();
		case 4:
			Budget.RemoveBudget(budget_id);
			Opportunity.RemoveOpportunity(opportunity_id);
			AILog.Error("Failed to build source airport");
			Finance.Repay();
		return false;
		case 5:
			source_tile = tile;
		return BuildDestination();
		case 6:
			Budget.RemoveBudget(budget_id);
			Opportunity.RemoveOpportunity(opportunity_id);
			AILog.Error("Failed to build destination airport");
			AIAirport.RemoveAirport(source_tile);
			Finance.Repay();
		return false;
		case 7:
			destination_tile = tile;
		return BuildPlanes();
		case 8: return BuildPlane();
		default:
			Budget.RemoveBudget(budget_id);
			Opportunity.RemoveOpportunity(opportunity_id);
			AILog.Error("Unknown state " + state);
		return false;
	}
}

function AirBuildOpportunity::BuildSource(){
	local price		= Airport.GetPrice(airport_type) * 1.2;

	if(price > Finance.GetAvailableMoney()){
		//AILog.Info("Waiting for enough money");
		return this.Sleep(50);
	}

	budget			= Math.min(price + Finance.GetAvailableMoney() * 0.1, (Finance.GetAvailableMoney() - Opportunity.GetMinimumPrice(opportunity_id)) / 2);
	town_id			= Opportunity.GetSourceTown(opportunity_id);
	failed_state	= 4;
	success_state	= 5;
	state 			= 2;
	return true;
}


function AirBuildOpportunity::BuildAirport(){
	list = Town.GetTiles(town_id, true, ceil(sqrt(pow(width, 2) + pow(height, 2))) * 1.5);

	list.Valuate(AITile.IsBuildableRectangle, width, height);
	list.KeepValue(1);

	list.Valuate(Airport.GetNoiseLevelIncrease, airport_type);
	list.RemoveAboveValue(Town.GetAllowedNoise(town_id));

	list.Valuate(AITile.GetCargoProduction, Opportunity.GetCargo(opportunity_id), width, height, Airport.GetAirportCoverageRadius(airport_type));
	list.Sort(AIList.SORT_BY_VALUE, false);
	list.KeepTop(Math.max(5, list.Count() / 4));
	if(list.Count() <= 0){
		AILog.Error("No tiles found");
	}

	state++;
	return true;
}

function AirBuildOpportunity::TryBuildAirport(){
	if(list.Count() <= 0){
		state = failed_state;
		return true;
	}

	tile = list.Begin();
	list.RemoveTop(1);

	local matrix = MapMatrix();
	matrix.AddRectangle(tile, width, height);
	if(!matrix.Level()){
		//AILog.Warning("Failed to make level");
		return true;
	}

	local cost = matrix.GetCosts();

	if(cost > 0){
		if(cost > budget){
			AILog.Warning("Not enough budget, need " + cost + " only have " + budget);
			return true;
		}

		if(!Finance.GetMoney(cost)){
			AILog.Warning("Failed to get " + cost);
			return true;
		}
	}
	Budget.Start(budget_id);
	matrix.MakeLevel();
	Budget.Stop(budget_id);

	if(!Finance.GetMoney(Airport.GetPrice(airport_type) * 1.5)) return true;

	Budget.Start(budget_id);
	if(!Airport.BuildAirport(tile, airport_type, AIStation.STATION_NEW)){
		Budget.Stop(budget_id);
		AILog.Error("Building airport failed: " + AIError.GetLastErrorString());
		state = failed_state;
		return true;
	}
	Budget.Stop(budget_id);

	state = success_state;
	return true;
}


function AirBuildOpportunity::BuildDestination(){
	local price		= Airport.GetPrice(airport_type) * 1.2;

	if(price > Finance.GetAvailableMoney()){
		//AILog.Info("Waiting for enough money");
		return this.Sleep(100);
	}

	budget			= Math.min(price + Finance.GetAvailableMoney() * 0.1, (Finance.GetAvailableMoney() - Opportunity.GetMinimumPrice(opportunity_id)) / 2);
	town_id			= Opportunity.GetDestinationTown(opportunity_id);
	failed_state	= 6;
	success_state	= 7;
	state 			= 2;
	return true;
}

function AirBuildOpportunity::BuildPlanes(){
	engine_id 				= Opportunity.GetEngine(opportunity_id);
	cargo_id				= Opportunity.GetCargo(opportunity_id);
	local distance 			= sqrt(AITile.GetDistanceSquareToTile(source_tile, destination_tile)).tointeger();
	local days				= Engine.GetEstimatedDays(engine_id, distance, 0.95);
	local maintenance_cost	= Airport.GetMaintenanceCost(airport_type) * 2;
	local running_cost		= AIEngine.GetRunningCost(engine_id) / 12;
	local income			= Cargo.GetCargoIncome(cargo_id, distance, (days * 0.9).tointeger()) * (Engine.GetCapacity(engine_id, cargo_id) * 1.12).tointeger() * 30 / days;
	local profit			= income - running_cost;
	needed_planes			= ceil(maintenance_cost / profit.tofloat()).tointeger();



	Station.SetProperty(Station.GetStationID(source_tile), "air.station.manager.check_date", AIDate.GetCurrentDate() + (Airport.GetDaysBetweenAcceptPlane(airport_type) * 2));
	Station.SetProperty(Station.GetStationID(destination_tile), "air.station.manager.check_date", AIDate.GetCurrentDate() + (Airport.GetDaysBetweenAcceptPlane(airport_type) * 2));

	state++;
	return BuildPlane();
}

function AirBuildOpportunity::BuildPlane(){
	Station.SetProperty(Station.GetStationID(source_tile), "air.station.manager.check_date", AIDate.GetCurrentDate() + (Airport.GetDaysBetweenAcceptPlane(airport_type) * 2));
	Station.SetProperty(Station.GetStationID(destination_tile), "air.station.manager.check_date", AIDate.GetCurrentDate() + (Airport.GetDaysBetweenAcceptPlane(airport_type) * 2));

	if(!Finance.GetMoney(Engine.GetPrice(engine_id))){
		//AILog.Info("Waiting for enough money");
		return this.Wait(3);
	}

	local vehicles = AIVehicleList_Station(Station.GetStationID(source_tile));
	if(vehicles.Count() < needed_planes){
		Budget.Start(budget_id);
		local vehicle_id = Vehicle.BuildVehicle(Airport.GetHangarOfAirport(source_tile), engine_id);
		Budget.Stop(budget_id);

		if (!Vehicle.IsValidVehicle(vehicle_id)){
			Finance.Repay();
			AILog.Error("Building plane failed: " + AIError.GetLastErrorString());
			return false;
		}
		//AILog.Info("Build " + Engine.GetName(engine_id));
		Vehicle.RefitVehicle(vehicle_id, cargo_id);

		AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_NONE);
		AIOrder.AppendOrder(vehicle_id, source_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
		AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_NONE);
		AIOrder.AppendOrder(vehicle_id, destination_tile, AIOrder.OF_GOTO_NEAREST_DEPOT);
		Vehicle.StartStopVehicle(vehicle_id);

		Finance.Repay();

		return this.Wait(Airport.GetDaysBetweenAcceptPlane(airport_type));

	}
	Budget.RemoveBudget(budget_id);
	Opportunity.RemoveOpportunity(opportunity_id);
	return false;
}