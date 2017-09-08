
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
	engines.Valuate(Engine.GetEstimatedIncomeByDays, opportunity.cargo_id, 100);
	engines.Sort(AIList.SORT_BY_VALUE, false);
	if(engines.Count() <= 0) return false;

	local engine_id = engines.Begin();

	local towns = AITownList();
	towns.RemoveList(Opportunity.towns);
	towns.RemoveItem(opportunity.source.town_id); // should not needed

	if(opportunity.vehicle_type == AIVehicle.VT_AIR){
		towns.Valuate(Town.CanBuildAirport);
		towns.KeepAboveValue(0);

		towns.Valuate(Town.GetAirportCount);
		towns.KeepValue(0);
	}

	towns.Valuate(AITown.GetDistanceSquareToTile, AITown.GetLocation(opportunity.source.town_id));

	towns.KeepBetweenValue(pow(Engine.GetEstimatedDistance(engine_id, 80, 0.95), 2).tointeger(), pow(Engine.GetEstimatedDistance(engine_id, 120, 0.95), 2).tointeger());

	towns.Valuate(AITown.GetPopulation);
	towns.Sort(AIList.SORT_BY_VALUE, false);
	towns.KeepTop(5);

	towns.Valuate(Town.GetAvailableCargo, opportunity.cargo_id);

	if(opportunity.vehicle_type == AIVehicle.VT_AIR){
		local cost = AIAirport.GetMaintenanceCostFactor(AIAirport.AT_SMALL) * 500;
		local capacity = (cost / AICargo.GetCargoIncome(opportunity.cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
		capacity = Math.max(capacity, Engine.GetCapacity(engine_id, opportunity.cargo_id));
		cost += (AIEngine.GetRunningCost(engine_id) / 24) * Math.max(1, capacity / Engine.GetCapacity(engine_id, opportunity.cargo_id));
		capacity = (cost / AICargo.GetCargoIncome(opportunity.cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
		capacity = Math.max(capacity, Engine.GetCapacity(engine_id, opportunity.cargo_id));
		towns.KeepAboveValue(capacity);
	}else{
		towns.KeepAboveValue(Engine.GetCapacity(engine_id, opportunity.cargo_id));
	}
	if(towns.Count() <= 0) return false;

	local town_id = List.RandPriority(towns);
	AILog.Info("" + AITown.GetName(opportunity.source.town_id) + " <==> " + AITown.GetName(town_id) + " with " + Cargo.GetName(opportunity.cargo_id));

	opportunity.destination = {
		type = Opportunity.LT_TOWN,
		town_id = town_id
	};
	state++;
	return true;
}

function AirFindDestination::GetCost(opportunity){
	local distance = Town.GetDistanceToTile(opportunity.source.town_id, Town.GetLocation(opportunity.destination.town_id));

	local engines = Engine.GetForCargo(opportunity.vehicle_type, opportunity.cargo_id);
	engines.Valuate(Engine.GetEstimatedIncomeByDistance, opportunity.cargo_id, distance);
	engines.Sort(AIList.SORT_BY_VALUE, false);
	if(engines.Count() <= 0) return false;

	local engine_id = engines.Begin();

	local days = Engine.GetEstimatedDays(engine_id, distance, 0.95);
	local numberOfPlanes = days * 2 / Airport.GetDaysBetweenAcceptPlane(Airport.AT_SMALL);

	AILog.Info("Engine: " + Engine.GetName(engine_id));
	AILog.Info("Days: " + days);
	AILog.Info("NumberOfPlanes: " + numberOfPlanes);



	return false;
}