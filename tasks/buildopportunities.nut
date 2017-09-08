
class BuildOpportunities extends Thread {
	constructor(){
	}
}

function BuildOpportunities::Run(){
	if(Opportunity.Count() <= 0) return this.Sleep(50);

	AILog.Info("Building....");


	local types = Airport.GetList();
	foreach (idx, value in types) {
	    AILog.Info(" - " + Airport.GetName(idx) + ": " + Airport.GetMaintenanceCostFactor(idx));
	}


	return this.Sleep(500);
}