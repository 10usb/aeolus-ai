
class AirFindDestination extends Thread {
	opportunity_id = null;
	state = 0;

	constructor(opportunity_id){
		this.opportunity_id = opportunity_id;
		this.state = 0;
	}
}

function AirFindDestination::Run(){
	local opportunity = Opportunity.Get(opportunity_id);
	if(!opportunity) return false;

	switch(state){
		case 0: return Initialize(opportunity);
		case 1: return GetCost(opportunity);
		default:
			AILog.Error("Unknown state " + state);
		return false;
	}
}

function AirFindDestination::Initialize(opportunity){
	local engines = Engine.GetForCargo(opportunity.vehicle_type, opportunity.cargo_id);
	engines.Valuate(Engine.GetEstimatedIncomeByDays, opportunity.cargo_id, 100, 0.95);
	engines.Sort(AIList.SORT_BY_VALUE, false);
	if(engines.Count() <= 0){
		// TODO remove opportunity from opportunities
		return false;
	}

	local towns = AITownList();
	towns.RemoveItem(opportunity.source.town_id);
	//towns.RemoveList(Opportunity.towns); // Remove all towns where destination is source

	towns.Valuate(Town.CanBuildAirport);
	towns.KeepAboveValue(0);

	towns.Valuate(Town.GetAirportCount);
	towns.KeepValue(0);

	towns.Valuate(Town.GetDistanceToTile, Town.GetLocation(opportunity.source.town_id));


	foreach(engine_id, value in engines){
		local temp = AIList();
		temp.AddList(towns);

		temp.KeepBetweenValue(Engine.GetEstimatedDistance(engine_id, 60, 0.95), Engine.GetEstimatedDistance(engine_id, 120, 0.95));

		temp.Valuate(AITown.GetPopulation);
		temp.Sort(AIList.SORT_BY_VALUE, false);
		temp.KeepTop(5);

		temp.Valuate(Town.GetAvailableCargo, opportunity.cargo_id);

		local selected = AIList();
		local airport_types = AIList();
		foreach (town_id, available_cargo in temp){
			local distance = Town.GetDistanceToTile(opportunity.source.town_id, Town.GetLocation(town_id));

			local days				= Engine.GetEstimatedDays(engine_id, distance, 0.95);
			local income			= Cargo.GetCargoIncome(opportunity.cargo_id, distance, (days*0.9).tointeger()) * (Engine.GetCapacity(engine_id, opportunity.cargo_id) * 1.12).tointeger() * 30 / days;
			local running_cost		= AIEngine.GetRunningCost(engine_id) / 12;
			local profit			= income - running_cost;

			foreach (airport_type in [ Airport.AT_SMALL ]) {
				local max_planes		= Math.round(days * 2.0 / Airport.GetDaysBetweenAcceptPlane(airport_type)).tointeger();
				local maintenance_cost	= Airport.GetMaintenanceCost(airport_type) * 2;
				local needed_planes		= ceil(maintenance_cost / profit.tofloat()).tointeger();
				if(needed_planes > max_planes) continue;

				local capacity = (Engine.GetCapacity(engine_id, opportunity.cargo_id) * 1.12 * needed_planes) * 30 / days;

				if(available_cargo > capacity){
					selected.AddItem(town_id, available_cargo);
					airport_types.AddItem(town_id, airport_type);
				}
			}
		}
		if(selected.Count() <= 0) continue;
		local town_id = List.RandPriority(selected);

		opportunity.engine_id = engine_id;
		opportunity.rawset("airport_type", airport_types.GetValue(town_id));
		opportunity.destination = {
			type = Opportunity.LT_TOWN,
			town_id = town_id
		};
		break;
	}

	if(opportunity.destination == null){
		// TODO remove opportunity from opportunities
		return false;
	}

	state++;
	return true;
}

function AirFindDestination::GetCost(opportunity){
	local distance = Town.GetDistanceToTile(opportunity.source.town_id, Town.GetLocation(opportunity.destination.town_id));

	local days					= Engine.GetEstimatedDays(opportunity.engine_id, distance, 0.95);
	local max_planes			= Math.round(days * 2.0 / Airport.GetDaysBetweenAcceptPlane(opportunity.airport_type)).tointeger();
	local maintenance_cost		= Airport.GetMaintenanceCost(opportunity.airport_type) * 2;

	local running_cost			= AIEngine.GetRunningCost(opportunity.engine_id) / 12;
	local income				= Cargo.GetCargoIncome(opportunity.cargo_id, distance, (days * 0.9).tointeger()) * (Engine.GetCapacity(opportunity.engine_id, opportunity.cargo_id) * 1.12).tointeger() * 30 / days;
	local profit				= income - running_cost;

	local needed_planes			= ceil(maintenance_cost / profit.tofloat()).tointeger();

	if(needed_planes > max_planes){
		// TODO remove opportunity from opportunities
		return false;
	}



	local available_cargo		= Math.min(Town.GetAvailableCargo(opportunity.source.town_id, opportunity.cargo_id), Town.GetAvailableCargo(opportunity.destination.town_id, opportunity.cargo_id));
	local posible_planes		= Math.round((available_cargo / (Engine.GetCapacity(opportunity.engine_id, opportunity.cargo_id) * 1.12)) * days / 30);

	opportunity.price			= Airport.GetPrice(opportunity.airport_type) * 2 + Engine.GetPrice(opportunity.engine_id) * Math.min(posible_planes, max_planes);
	opportunity.minimum_price	= Airport.GetPrice(opportunity.airport_type) * 2 + Engine.GetPrice(opportunity.engine_id) * needed_planes;
	opportunity.monthly_profit	= Math.min(posible_planes, max_planes) * profit - maintenance_cost;
	if(opportunity.monthly_profit <= 0){
		// TODO remove opportunity from opportunities
		return false;
	}
	opportunity.buildable		= 1;


	AILog.Info("Found opportunity " + Town.GetName(opportunity.source.town_id) + " <==> " + Town.GetName(opportunity.destination.town_id) + " with " + Cargo.GetName(opportunity.cargo_id) + " (" + days + " days of travel)");
	// //AILog.Info("Engine: " + Engine.GetName(opportunity.engine_id) + " (" + Engine.GetCapacity(opportunity.engine_id, opportunity.cargo_id) + ")");
	// //AILog.Info("Days: " + Engine.GetEstimatedDays(opportunity.engine_id, distance, 0.95));
	// AILog.Info("planes: " + needed_planes + " / " + posible_planes + " / " + max_planes);
	// //AILog.Info("running_cost: " + running_cost);
	// //AILog.Info("maintenance_cost: " + maintenance_cost);
	// //AILog.Info("income: " + income);
	// //AILog.Info("profit: " + profit);

	// AILog.Info("price : " + opportunity.price);
	// AILog.Info("profit: " + opportunity.monthly_profit);
	// AILog.Info("months: " + ceil(opportunity.price.tofloat() / opportunity.monthly_profit));

	return false;
}