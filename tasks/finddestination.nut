
class FindDestination extends Thread {
	opportunity_id = null;
	state = 0;

	constructor(opportunity_id){
		this.opportunity_id = opportunity_id;
		this.state = 0;
	}
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
	}else{
		AILog.Warning("Unsupported location type");
		return false;
	}
}

function FindDestination::ProcessIndustry(opportunity){
	AILog.Info("----------------------------------");
	AILog.Info("Cargo: " + AICargo.GetCargoLabel(opportunity.cargo_id));

	local engines = Engine.GetForCargo(AIVehicle.VT_RAIL, opportunity.cargo_id);
	engines.Valuate(Engine.GetEstimatedIncome, opportunity.cargo_id, 100);
	engines.Sort(AIList.SORT_BY_VALUE, false);

	local engine_id = engines.Begin();
	//engines.Valuate(Engine.GetEstimatedDistance);

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