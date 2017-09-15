
class FindDestination extends Thread {
	opportunity_id = null;
	state = 0;

	constructor(opportunity_id){
		this.opportunity_id = opportunity_id;
		this.state = 0;
	}
}

function FindDestination::GetName(){
	return "FindDestination";
}

function FindDestination::Run(){
	local opportunity = Opportunity.Get(opportunity_id);
	if(!opportunity) return false;

	switch(state){
		case 0: return Initialize(opportunity);
		default:
			AILog.Error("Unknown state " + state);
		return false;
	}
}


function FindDestination::Initialize(opportunity){
	if(opportunity.source.type == Opportunity.LT_INDUSTRY){
		return ProcessIndustry(opportunity);
	}else if(opportunity.source.type == Opportunity.LT_TOWN){
		return ProcessTown(opportunity);
	}else{
		AILog.Warning("Unsupported location type");
		return false;
	}
}

function FindDestination::ProcessIndustry(opportunity){
	AILog.Info("----------------------------------");
	AILog.Info("Cargo: " + AICargo.GetCargoLabel(opportunity.cargo_id));

	local engines = Engine.GetForCargo(opportunity.vehicle_type, opportunity.cargo_id);
	engines.Valuate(Engine.GetEstimatedIncome, opportunity.cargo_id, 100);
	engines.Sort(AIList.SORT_BY_VALUE, false);

	local engine_id = engines.Begin();

	AILog.Info(AIEngine.GetName(engine_id));
	AILog.Info("min: " + Engine.GetEstimatedDistance(engine_id, 80));
	AILog.Info("max: " + Engine.GetEstimatedDistance(engine_id, 120));

	local industries = AIIndustryList_CargoAccepting(opportunity.cargo_id);
	industries.Valuate(AIIndustry.GetDistanceSquareToTile, AIIndustry.GetLocation(opportunity.source.industry_id));
	industries.KeepBetweenValue(pow(Engine.GetEstimatedDistance(engine_id, 80), 2).tointeger(), pow(Engine.GetEstimatedDistance(engine_id, 120), 2).tointeger());

	foreach(industry_id, value in industries){
		AILog.Info("  " + sqrt(value).tointeger() + " = " + AIIndustry.GetName(industry_id));
	}

	//Aeolus.Sleep(50);
	return false;
}

function FindDestination::ProcessTown(opportunity){
	local engines = Engine.GetForCargo(opportunity.vehicle_type, opportunity.cargo_id);
	engines.Valuate(Engine.GetEstimatedIncome, opportunity.cargo_id, 100);
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

	local efficiency = 0.4;
	if(opportunity.vehicle_type == AIVehicle.VT_AIR){
		efficiency = 0.95;
	}
	towns.KeepBetweenValue(pow(Engine.GetEstimatedDistance(engine_id, 80, efficiency), 2).tointeger(), pow(Engine.GetEstimatedDistance(engine_id, 120, efficiency), 2).tointeger());

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
	AILog.Info("" + AITown.GetName(opportunity.source.town_id) + " <==> " + AITown.GetName(town_id) + " with " + AICargo.GetCargoLabel(opportunity.cargo_id));

	opportunity.destination = {
		type = Opportunity.LT_TOWN,
		town_id = town_id
	};

	return false;
}