
class BuildOpportunities extends Thread {
	constructor(){
	}
}

function BuildOpportunities::Run(){
	if(Storage.ValueExists("opportunity.build_id") && Opportunity.IsValidOpportunity(Storage.GetValue("opportunity.build_id"))){
		 return this.Sleep(15);
	}

	if(Opportunity.GetCount() <= 0) return this.Sleep(50);

	local opportunities = Opportunity.GetList();
	opportunities.Valuate(Opportunity.IsBuildable);
	opportunities.KeepValue(1);

	if(opportunities.Count() <= 0) return this.Sleep(30);

	opportunities.Valuate(Opportunity.GetMinimumPrice);
	opportunities.KeepBelowValue(Finance.GetAvailableMoney() - Finance.GetMonthlyIncome());

	if(opportunities.Count() <= 0){
		// Remove opportunity to make room for new ones
		return this.Sleep(30);
	}

	opportunities.Valuate(BuildOpportunities.GetMonths);
	local max = List.GetMax(opportunities) + 1;

	local temp = AIList();
	foreach(opportunity_id, value in opportunities){
		temp.AddItem(opportunity_id, max - value);
	}

	local opportunity_id = List.RandPriority(temp);

	if(Opportunity.GetVehicleType(opportunity_id) == AIVehicle.VT_AIR){
		Storage.SetValue("opportunity.build_id", opportunity_id); // TODO should be cache
		Aeolus.AddThread(AirBuildOpportunity(opportunity_id));
	}else{
		throw("Can't build this");
	}
	return this.Sleep(15);
}

function BuildOpportunities::GetMonths(opportunity_id){
	return ceil(Opportunity.GetPrice(opportunity_id).tofloat() / Opportunity.GetMonthlyProfit(opportunity_id)).tointeger();
}