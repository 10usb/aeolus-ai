
class FindOpportunities extends Thread {
	fails = 0;

	constructor(){
	}
}

function FindOpportunities::Run(){
	local cargo_id = Company.GetFavoredCargo();

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

	if(fails > 10) this.Sleep(50 * fails);
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

	industries.RemoveList(Opportunity.industries);

	industries.Valuate(Industry.GetAvailableCargo, cargo_id);
	industries.KeepAboveValue(0);

	industries.Sort(AIList.SORT_BY_VALUE, false);
	industries.KeepTop(Math.min(5, Math.max(1, industries.Count() / 4)));

	if(industries.Count() <= 0) return false;
	local industry_id = List.RandPriority(industries);

	AILog.Info("Found opportunity at " + AIIndustry.GetName(industry_id) + " with " + Industry.GetAvailableCargo(industry_id, cargo_id) + " " + Cargo.GetName(cargo_id));
	local opportunity_id = Opportunity.CreateIndustry(industry_id, cargo_id);
	if(opportunity_id <= 0) return false;

	Aeolus.AddThread(FindDestination(opportunity_id));
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
	towns.RemoveList(Opportunity.towns);

	towns.Valuate(Town.CanBuildAirport);
	towns.KeepAboveValue(0);

	towns.Valuate(Town.GetAirportCount);
	towns.KeepValue(0);

	towns.Valuate(AITown.GetPopulation);
	towns.Sort(AIList.SORT_BY_VALUE, false);
	towns.KeepTop(5);

	towns.Valuate(Town.GetAvailableCargo, cargo_id);

	local cost = Airport.GetMaintenanceCost(AIAirport.AT_SMALL);

	local capacity = (cost / AICargo.GetCargoIncome(cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
	capacity = Math.max(capacity, Engine.GetCapacity(engine_id, cargo_id));
	cost += (AIEngine.GetRunningCost(engine_id) / 24) * Math.max(1, capacity / Engine.GetCapacity(engine_id, cargo_id));
	capacity = (cost / AICargo.GetCargoIncome(cargo_id, Engine.GetEstimatedDistance(engine_id, 80, 0.7), 80).tofloat()).tointeger();
	capacity = Math.max(capacity, Engine.GetCapacity(engine_id, cargo_id));
	towns.KeepAboveValue(capacity);

	if(towns.Count() <= 0) return false;

	local town_id = List.RandPriority(towns);

	local opportunity_id = Opportunity.CreateTown(town_id, cargo_id, AIVehicle.VT_AIR);
	if(opportunity_id < 0) return false;

	Aeolus.AddThread(AirFindDestination(opportunity_id));
	return true;
}

function FindOpportunities::FindIndustryToTown(cargo_id){
	// Planes can't carry any cargo from industries
	if(Company.GetFavoredVehicleType() == AIVehicle.VT_AIR) return false;

	AILog.Warning("Industry <==> Town opportunities not yet supported (" + AICargo.GetCargoLabel(cargo_id) + ")");
	return false;
}