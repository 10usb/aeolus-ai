
class BuildOpportunities extends Thread {
	constructor(){
	}
}

function BuildOpportunities::Run(){
	if(Opportunity.GetCount() <= 0) return this.Sleep(50);


	local opportunities = Opportunity.GetList();
	opportunities.Valuate(Opportunity.IsBuildable);
	opportunities.KeepValue(1);

	if(Opportunity.GetCount() <= 0) return this.Sleep(50);

	opportunities.Valuate(Opportunity.GetMinimumPrice);
	opportunities.KeepBelowValue(Finance.GetAvailableMoney());

	if(Opportunity.GetCount() <= 0) return this.Sleep(50);

	opportunities.Valuate(BuildOpportunities.GetMonths);
	local max = List.GetMax(opportunities) + 1;

	local temp = AIList();
	foreach(opportunity_id, value in opportunities){
		temp.AddItem(opportunity_id, max - value);
	}

	local opportunity_id = List.RandPriority(temp);

    AILog.Warning("Building " + Opportunity.GetSourceName(opportunity_id) + " <==> " + Opportunity.GetDestinationName(opportunity_id) + " with " + Cargo.GetName(Opportunity.GetCargo(opportunity_id)));
	AILog.Info("  price     : " + Opportunity.GetPrice(opportunity_id));
	AILog.Info("  min. price: " + Opportunity.GetMinimumPrice(opportunity_id));
	AILog.Info("  profit    : " + Opportunity.GetMonthlyProfit(opportunity_id));
	AILog.Info("  months    : " + ceil(Opportunity.GetPrice(opportunity_id).tofloat() / Opportunity.GetMonthlyProfit(opportunity_id)));

	return this.Sleep(5000);
}

function BuildOpportunities::GetMonths(opportunity_id){
	return ceil(Opportunity.GetPrice(opportunity_id).tofloat() / Opportunity.GetMonthlyProfit(opportunity_id)).tointeger();
}