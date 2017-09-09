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
		cargo_id = cargo_id
		source = {
			type = Opportunity.LT_INDUSTRY,
			industry_id = industry_id
		},
		destination = null,
		engine_id = null,
		price = 0,
		monthly_profit = 0
	});
	Opportunity.industries.AddItem(industry_id, id);
	return id;
}


function Opportunity::CreateTown(town_id, cargo_id){
	if(Opportunity.towns.HasItem(town_id)) return 0;

	local id = ++Opportunity.global.increment;

	Opportunity.global.list.rawset(id, {
		id = id,
		vehicle_type = Company.GetFavoredVehicleType(),
		cargo_id = cargo_id,
		source = {
			type = Opportunity.LT_TOWN,
			town_id = town_id
		},
		destination = null,
		engine_id = null,
		price = 0,
		monthly_profit = 0
	});
	Opportunity.towns.AddItem(town_id, id);
	return id;
}