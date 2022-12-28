
class FindOpportunities extends TaskQueue {
	fails = 0;

	constructor(){
		::TaskQueue.constructor();
	}
}

function FindOpportunities::GetName(){
	return "FindOpportunities";
}

function FindOpportunities::RunEmpty(){
	local opportunities = OpportunityList();

	if(opportunities.Count() < 10){
		return this.FindNew();
	}else{
		// TODO test every opportunity once in a while, if it is still valid
		Log.Info("Hey, look we reached our maximum opportunities");
		return this.Sleep(500);
	}
}

function FindOpportunities::FindNew(){
	local personality_trait = PersonalityTrait.GetFavored();

	switch(personality_trait){
		case PersonalityTrait.PT_INNER_CITY | Vehicle.VT_ROAD:
			EnqueueTask(Road_FindInnerCity());
		break;
		case PersonalityTrait.PT_INVALID:
			Log.Error("Failed in having a personality");
			return false;
		default:
			Log.Info("Decreasing favor " + PersonalityTrait.GetName(personality_trait));
			PersonalityTrait.DecreaseFavor(personality_trait);
	}
	
	return true;
}

function FindOpportunities::RunOld(){
	local cargo_id = Company.GetFavoredCargo();

	local opportunities = OpportunityList();
	if(Storage.ValueExists("opportunity.build_id")){
		opportunities.RemoveItem(Storage.GetValue("opportunity.build_id"));
	}
	opportunities.Valuate(Opportunity.GetCreated);
	opportunities.KeepBelowValue(AIDate.GetCurrentDate() - 365);
	foreach(opportunity_id, dummy in opportunities){
		Opportunity.RemoveOpportunity(opportunity_id);
	}

	if(Opportunity.Count() > 3) return this.Sleep(500);

	if(AICargo.GetTownEffect(cargo_id) == AICargo.TE_NONE){
		if(!FindOpportunities.FindIndustryToIndustry(cargo_id)){
			Company.DecreaseCargoFavor(cargo_id);
			if(++fails > 4){
				Company.DecreaseVehicleTypeFavor(Company.GetFavoredVehicleType());
			}
		}else{
			fails = 0;
		}
	}else if(AICargo.IsFreight(cargo_id)){
		if(!FindOpportunities.FindIndustryToTown(cargo_id)){
			Company.DecreaseCargoFavor(cargo_id);

			if(++fails > 4){
				Company.DecreaseVehicleTypeFavor(Company.GetFavoredVehicleType());
			}
		}else{
			fails = 0;
		}
	}else{
		if(!FindOpportunities.FindTownToTown(cargo_id)){
			Company.DecreaseCargoFavor(cargo_id);

			if(++fails > 4){
				Company.DecreaseVehicleTypeFavor(Company.GetFavoredVehicleType());
			}
		}else{
			fails = 0;
		}
	}

	if(fails > 10) this.Sleep(50 * Math.min(20, fails));
	return true;
}

function FindOpportunities::FindIndustryToIndustry(cargo_id){
	// Planes can't carry any cargo from industries
	if(Company.GetFavoredVehicleType() == AIVehicle.VT_AIR) return false;

	if(Company.GetFavoredVehicleType() != AIVehicle.VT_RAIL){
		AILog.Warning("Industry <==> Industry opportunities other then VT_RAIL are not yet supported (" + Cargo.GetName(cargo_id) + ")");
		return false;
	}

	local industries = AIIndustryList_CargoProducing(cargo_id);
	industries.Valuate(Industry.GetAvailableCargo, cargo_id);
	industries.KeepAboveValue(0);

	industries.Sort(AIList.SORT_BY_VALUE, false);
	industries.KeepTop(Math.min(5, Math.max(1, industries.Count() / 4)));

	if(industries.Count() <= 0) return false;
	local industry_id = Lists.RandPriority(industries);

	AILog.Info("Found opportunity at " + Industry.GetName(industry_id) + " with " + Industry.GetAvailableCargo(industry_id, cargo_id) + " " + Cargo.GetName(cargo_id));
	local opportunity_id = Opportunity.CreateIndustry(industry_id, cargo_id, AIVehicle.VT_RAIL);
	if(opportunity_id <= 0) return false;

	_parent.EnqueueTask(RailFindDestinationIndustry(opportunity_id));
	return true;
}

function FindOpportunities::FindTownToTown(cargo_id){
	if(Company.GetFavoredVehicleType() != AIVehicle.VT_AIR){
		AILog.Warning("Town <==> Town opportunities other then VT_AIR are not yet supported (" + Cargo.GetName(cargo_id) + ")");
		return false;
	}

	local engines = Engine.GetForCargo(Company.GetFavoredVehicleType(), cargo_id);
	engines.Valuate(Engine.GetEstimatedIncomeByDays, cargo_id, 100, 0.95);
	engines.Sort(AIList.SORT_BY_VALUE, false);
	if(engines.Count() <= 0) return false;
	local engine_id = engines.Begin();

	
	local towns = AITownList();
	towns.Valuate(Town.GetPopulation);
	Company.GetTownPreference().Update(towns);

	towns = Company.GetTownPreference().GetList();
	//towns.RemoveList(Opportunity.towns);

	towns.Valuate(Town.GetAvailableCargo, cargo_id);

	local cost = Airport.GetMaintenanceCost(AIAirport.AT_SMALL);

	local capacity = (cost / AICargo.GetCargoIncome(cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
	capacity = Math.max(capacity, Engine.GetCapacity(engine_id, cargo_id));
	cost += (AIEngine.GetRunningCost(engine_id) / 24) * Math.max(1, capacity / Engine.GetCapacity(engine_id, cargo_id));
	capacity = (cost / AICargo.GetCargoIncome(cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
	capacity = Math.max(capacity, Engine.GetCapacity(engine_id, cargo_id));
	towns.KeepAboveValue(capacity);

	if(towns.Count() <= 0) return false;

	local town_id = Lists.RandPriority(towns);

	local opportunity_id = Opportunity.CreateTown(town_id, cargo_id, AIVehicle.VT_AIR);
	if(opportunity_id < 0) return false;

	_parent.EnqueueTask(AirFindDestination(opportunity_id));
	return true;
}

function FindOpportunities::FindIndustryToTown(cargo_id){
	// Planes can't carry any cargo from industries
	if(Company.GetFavoredVehicleType() == AIVehicle.VT_AIR) return false;

	AILog.Warning("Industry <==> Town opportunities not yet supported (" + AICargo.GetCargoLabel(cargo_id) + ")");
	return false;
}