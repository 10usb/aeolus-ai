
class BuildOpportunities extends Thread {
	constructor(){
	}
}

function BuildOpportunities::Run(){
	if(Opportunity.Count() <= 0) return this.Sleep(50);

	AILog.Info("Building....");


	local types = AirPort.GetTypes();
	foreach (idx, value in types) {
	    AILog.Info(" - " + AirPort.GetTypeName(idx) + ": " + AIAirport.GetMaintenanceCostFactor(idx));
	}


	return this.Sleep(500);
}