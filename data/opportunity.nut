class Opportunity {
	static LT_NONE = 0;
	static LT_INDUSTRY = 1;
	static LT_TOWN = 2;

	static industries = AIList();
	static towns = AIList();
	static global = {
		increment = 0,
		list = {},
	};
}

function Opportunity::Count(){
	return Opportunity.global.list.len();
}


function Opportunity::Get(opportunity_id){
	if(!Opportunity.global.list.rawin(opportunity_id)){
		return null;
	}
	return Opportunity.global.list.rawget(opportunity_id);
}

function Opportunity::GetByIndustry(industry_id){
	if(!Opportunity.industries.HasItem(industry_id)){
		return null;
	}
	return Opportunity.global.list.rawget(Opportunity.industries.GetValue(industry_id));
}


function Opportunity::CreateIndustry(industry_id, cargo_id){
	if(Opportunity.industries.HasItem(industry_id)) return 0;

	local id = ++Opportunity.global.increment;

	Opportunity.global.list.rawset(id, {
		id = id,
		vehicle_type = Company.GetFavoredVehicleType(),
		cargo_id = cargo_id,
		source = {
			type = Opportunity.LT_INDUSTRY,
			industry_id = industry_id
		},
		destination = null
	});
	Opportunity.industries.AddItem(industry_id, id);
	return id;
}


function Opportunity::GetIndustryProfit(destination_industry_id, source_industry_id, type){
	local cargos = AICargoList_IndustryProducing(source_industry_id);
	cargos.KeepList(AICargoList_IndustryAccepting(destination_industry_id));

	local distance	= AIMap.DistanceManhattan(AIIndustry.GetLocation(source_industry_id), AIIndustry.GetLocation(destination_industry_id));
	local profit	= 0;
	foreach(cargo_id, dummy in cargos){
		local production = AIIndustry.GetLastMonthProduction(source_industry_id, cargo_id) - AIIndustry.GetLastMonthTransported(source_industry_id, cargo_id);
		profit+= Opportunity.GetBestMonthlyProfit(cargo_id, distance, production, type);
	}
	return profit;
}

function Opportunity::GetMonthlyEngineProfit(cargo_id, distance, production, type){
	local engines = AIEngineList(type);
	engines.Valuate(AIEngine.IsBuildable);
	engines.KeepValue(1);
	engines.Valuate(AIEngine.IsWagon);
	engines.KeepValue(0);

	local possibilities = AIList();

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.GetCargoType);
	temp.KeepValue(cargo_id);
	possibilities.AddList(temp);

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.CanRefitCargo, cargo_id);
	temp.KeepValue(1);
	possibilities.AddList(temp);

	local temp = AIList();
	temp.AddList(engines);
	temp.Valuate(AIEngine.CanPullCargo, cargo_id);
	temp.KeepValue(1);
	possibilities.AddList(temp);

	if(possibilities.Count() <=0){
		// decrease favor
		return null
	}

	possibilities.Valuate(Opportunity.GetEngineMonthlyProfit, cargo_id, distance, production);
	possibilities.Sort(AIList.SORT_BY_VALUE, false);

	return possibilities;
}

function Opportunity::GetBestMonthlyProfit(cargo_id, distance, production, type){
	local possibilities = Opportunity.GetMonthlyEngineProfit(cargo_id, distance, production, type);
	if(possibilities==null){
		return 0;
	}

	return possibilities.GetValue(possibilities.Begin());
}

function Opportunity::GetEngineMonthlyProfit(engine_id, cargo_id, distance, production){
	local days = (distance * 44.3 / AIEngine.GetMaxSpeed(engine_id)).tointeger();
	if(days < 10 || days > 180) return 0;

	local cost = 0;

	if(AIEngine.GetVehicleType(engine_id) == AIVehicle.VT_RAIL){
		local pullingWeight = (1 / (pow(AIEngine.GetMaxSpeed(engine_id), 2) / 2.0 / ((distance * 0.2) * 44.0)) * (AIEngine.GetPower(engine_id) * 2.2)).tointeger() - AIEngine.GetWeight(engine_id);

		local wagons = AIEngineList(AIVehicle.VT_RAIL);
		wagons.Valuate(AIEngine.IsBuildable);
		wagons.KeepValue(1);
		wagons.Valuate(AIEngine.IsWagon);
		wagons.KeepValue(1);
		wagons.Valuate(AIEngine.GetCargoType);
		wagons.KeepValue(cargo_id);
		//engines.Valuate(AIEngine.GetRailType);
		//engines.KeepValue(AIEngine.GetRailType(engine_id));

		local wagons_id		= wagons.Begin();
		local wagonWeight	= AIEngine.GetWeight(wagons_id) + Opportunity.GetCargoWeight(cargo_id, AIEngine.GetCapacity(wagons_id));
		local maxWagons		= pullingWeight / wagonWeight;
		local neededWagons	= Math.round((production * days * 2 / 30.5) / AIEngine.GetCapacity(wagons_id));
		local trainCapacity	= Math.min(maxWagons, neededWagons) * AIEngine.GetCapacity(wagons_id);
		local neededTrains	= Math.ceil((production * days * 2 / 30.5) / trainCapacity).tointeger();

		cost = AIEngine.GetRunningCost(engine_id) * neededTrains + (AIEngine.GetPrice(engine_id) / AIEngine.GetMaxAge(engine_id) / 12);

	}

	return AICargo.GetCargoIncome(cargo_id, distance, days) * production - cost;
}

function Opportunity::GetCargoWeight(cargo_id, amount){
	if(AICargo.GetCargoLabel(cargo_id)=="PASS") return amount / 20;
	if(AICargo.GetCargoLabel(cargo_id)=="MAIL") return amount / 4;
	if(AICargo.GetCargoLabel(cargo_id)=="GOOD") return amount / 2;
	if(AICargo.GetCargoLabel(cargo_id)=="VALU") return amount / 10;
	if(AICargo.GetCargoLabel(cargo_id)=="LVST") return amount / 5;
	return amount;
}