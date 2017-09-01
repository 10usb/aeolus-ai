
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
	engines.Valuate(Engine.GetWagonLength, opportunity.cargo_id);

	foreach(engine_id, length in engines){
		AILog.Info(AIEngine.GetName(engine_id) + " (" + length + ")");
	}

	Aeolus.Sleep(50);

	local cargos = AICargoList_IndustryProducing(opportunity.source.industry_id);

	local industries = AIIndustryList_CargoAccepting(opportunity.cargo_id)

	industries.Valuate(Opportunity.GetIndustryProfit, opportunity.source.industry_id, opportunity.vehicle_type);
	industries.Sort(AIList.SORT_BY_VALUE, false);
	if(industries.Count() > 0){
		industries.KeepAboveValue(industries.GetValue(industries.Begin()) / 3);
	}

	foreach(industry_id, value in industries){
		//AILog.Info("  " + value + " = " + AIIndustry.GetName(industry_id));
	}

	local destination_industry_id = List.RandPriority(industries);
	AILog.Info("    " + AIIndustry.GetName(destination_industry_id));
	cargos.KeepList(AICargoList_IndustryAccepting(destination_industry_id));

	local distance	= AIMap.DistanceManhattan(AIIndustry.GetLocation(opportunity.source.industry_id), AIIndustry.GetLocation(destination_industry_id));
	local profit	= 0;
	foreach(cargo_id, dummy in cargos){
		local production = AIIndustry.GetLastMonthProduction(opportunity.source.industry_id, cargo_id) - AIIndustry.GetLastMonthTransported(opportunity.source.industry_id, cargo_id);

		local engines = Opportunity.GetMonthlyEngineProfit(cargo_id, distance, production, opportunity.vehicle_type);
		AILog.Info("    " + AIEngine.GetName(engines.Begin()) + " transporting " + AICargo.GetCargoLabel(cargo_id));
	}
	return false;
}