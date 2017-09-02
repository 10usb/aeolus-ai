
class FindOpportunities extends Thread {
	constructor(){
	}
}

function FindOpportunities::Run(){
	local cargo_id = Company.GetFavoredCargo();

	if(Opportunity.Count() > 10) return this.Sleep(500);

	if(AICargo.GetTownEffect(cargo_id) == AICargo.TE_NONE){
		local industries = AIIndustryList_CargoProducing(cargo_id);

		industries.RemoveList(Opportunity.industries);

		industries.Valuate(Industry.GetAvailableCargo, cargo_id);
		industries.KeepAboveValue(0);

		industries.Sort(AIList.SORT_BY_VALUE, false);
		industries.KeepTop(Math.min(5, Math.max(1, industries.Count() / 4)));

		if(industries.Count()){
			local industry_id = List.RandPriority(industries);

			AILog.Info("Found opportunity at " + AIIndustry.GetName(industry_id) + " with " + Industry.GetAvailableCargo(industry_id, cargo_id) + " " + AICargo.GetCargoLabel(cargo_id));
			local opportunity_id = Opportunity.CreateIndustry(industry_id, cargo_id);
			if(opportunity_id > 0){
				Aeolus.AddThread(FindDestination(opportunity_id));
			}
		}else{
			Company.DecreaseCargoFavor(cargo_id);
		}
	}else if(AICargo.IsFreight(cargo_id)){
		AILog.Warning("Industry <==> Town opportunities not yet supported (" + AICargo.GetCargoLabel(cargo_id) + ")");
		Company.DecreaseCargoFavor(cargo_id);
	}else{
		AILog.Warning("Town <==> Town opportunities not yet supported (" + AICargo.GetCargoLabel(cargo_id) + ")");
		Company.DecreaseCargoFavor(cargo_id);
	}

	return true;
}