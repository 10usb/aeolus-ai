
class RailFindDestinationIndustry extends Thread {
	opportunity_id = null;
	state = 0;

	constructor(opportunity_id){
		this.opportunity_id = opportunity_id;
		this.state = 0;
	}
}

function RailFindDestinationIndustry::GetName(){
	return "RailFindDestinationIndustry";
}

function RailFindDestinationIndustry::Run(){
	AILog.Info("----------------------------------");
	AILog.Info("Cargo: " + Cargo.GetName(Opportunity.GetCargo(opportunity_id)));

	local engines = Engine.GetForCargo(Opportunity.GetVehicleType(opportunity_id), Opportunity.GetCargo(opportunity_id));
	engines.Valuate(Engine.GetEstimatedIncomeByDays, Opportunity.GetCargo(opportunity_id), 100, 0.8);
	engines.Sort(AIList.SORT_BY_VALUE, false);

	local engine_id = engines.Begin();

	AILog.Info(Engine.GetName(engine_id));
	AILog.Info("min: " + Engine.GetEstimatedDistance(engine_id, 80, 0.8));
	AILog.Info("max: " + Engine.GetEstimatedDistance(engine_id, 120, 0.8));

	local industries = AIIndustryList_CargoAccepting(Opportunity.GetCargo(opportunity_id));
	industries.Valuate(AIIndustry.GetDistanceSquareToTile, Industry.GetLocation(Opportunity.GetSourceId(opportunity_id)));
	industries.KeepBetweenValue(pow(Engine.GetEstimatedDistance(engine_id, 80, 0.8), 2).tointeger(), pow(Engine.GetEstimatedDistance(engine_id, 120, 0.8), 2).tointeger());

	foreach(industry_id, value in industries){
		AILog.Info("  " + sqrt(value).tointeger() + " = " + AIIndustry.GetName(industry_id));
	}

	local start = AIDate.GetCurrentDate();
	local finder = RailScanFinder(6);

	finder.AddStartpoints(TranslatedTileList(Industry.GetLocation(Opportunity.GetSourceId(opportunity_id)), 4, 4));
	finder.AddEndpoint(TranslatedTileList(Industry.GetLocation(industries.Begin()), 4, 4));

	finder.Init();
	local steps = 0;
	while(finder.Step()) steps++;
	AILog.Info("Days: " + (AIDate.GetCurrentDate() - start));
	AILog.Info("Steps: " + steps);

	finder.GetPath();



	Aeolus.Sleep(500);
	
	switch(state){
		default:
			Opportunity.RemoveOpportunity(opportunity_id);
			AILog.Error("Unknown state " + state);
		return false;
	}
}