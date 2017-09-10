
class BuildOpportunities extends Thread {
	constructor(){
	}
}

function BuildOpportunities::Run(){
	if(Opportunity.GetCount() <= 0) return this.Sleep(50);


	local opportunities = Opportunity.GetList();
	opportunities.Valuate(Opportunity.IsBuildable);
	opportunities.KeepValue(1);

	if(opportunities.Count() <= 0) return this.Sleep(50);

	opportunities.Valuate(Opportunity.GetMinimumPrice);
	opportunities.KeepBelowValue(Finance.GetAvailableMoney());

	if(opportunities.Count() <= 0) return this.Sleep(500);

	opportunities.Valuate(BuildOpportunities.GetMonths);
	local max = List.GetMax(opportunities) + 1;

	local temp = AIList();
	foreach(opportunity_id, value in opportunities){
		temp.AddItem(opportunity_id, max - value);
	}

	local opportunity_id = List.RandPriority(temp);

	if(Opportunity.GetVehicleType(opportunity_id) == AIVehicle.VT_AIR){
		Aeolus.AddThread(AirBuildOpportunity(opportunity_id));
	}else{
		throw("Can't build this");
	}
	return this.Sleep(500);
}

function BuildOpportunities::GetMonths(opportunity_id){
	return ceil(Opportunity.GetPrice(opportunity_id).tofloat() / Opportunity.GetMonthlyProfit(opportunity_id)).tointeger();
}