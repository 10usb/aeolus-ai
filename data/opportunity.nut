class Opportunity {
	static LT_NONE = 0;
	static LT_INDUSTRY = 1;
	static LT_TOWN = 2;

	static industries = AIList();
	static towns = AIList();
}


function Opportunity::GetCount(){
	if(Storage.ValueExists("opportunities")) return Storage.GetValue("opportunities").len();
	return 0;
}

function Opportunity::GetList(){
	local list = AIList();
	if(Storage.ValueExists("opportunities")){
		foreach(opportunity_id, dummy in Storage.GetValue("opportunities")){
			list.AddItem(opportunity_id, 0);
		}
	}
	return list;
}

function Opportunity::IsValidOpportunity(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) return 0;
	return 1;
}

function Opportunity::RemoveOpportunity(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	opportunities.rawdelete(opportunity_id);
}

function Opportunity::RemoveWithTown(town_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	local location = null;
	foreach(opportunity_id, opportunity in opportunities){
		location = opportunities.rawget(opportunity_id).source;
		if(location.type == Opportunity.LT_TOWN && location.town_id == town_id){
			opportunities.rawdelete(opportunity_id);
			continue;
		}
		location = opportunities.rawget(opportunity_id).destination;
		if(location != null && location.type == Opportunity.LT_TOWN && location.town_id == town_id){
			opportunities.rawdelete(opportunity_id);
			continue;
		}
	}
}

function Opportunity::IsBuildable(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).buildable;
}

function Opportunity::GetPrice(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).price;
}

function Opportunity::GetMinimumPrice(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).minimum_price;
}

function Opportunity::GetMonthlyProfit(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).monthly_profit;
}

function Opportunity::GetEngine(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).engine_id;
}

function Opportunity::GetCreated(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).created;
}

function Opportunity::GetVehicleType(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).vehicle_type;
}

function Opportunity::GetCargo(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).cargo_id;
}

function Opportunity::GetSourceName(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");

	local location = opportunities.rawget(opportunity_id).source;
	switch(location.type){
		case Opportunity.LT_INDUSTRY: return Industry.GetName(location.industry_id);
		case Opportunity.LT_TOWN: return Town.GetName(location.town_id);
		default: throw("Unknown source type");
	}
}

function Opportunity::GetSourceTown(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");

	local location = opportunities.rawget(opportunity_id).source;
	if(location.type != Opportunity.LT_TOWN) throw("Unknown source type");
	return location.town_id;
}

function Opportunity::GetDestinationName(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");

	local location = opportunities.rawget(opportunity_id).destination;
	if(location == null) throw("No destination for this opportunity");
	switch(location.type){
		case Opportunity.LT_INDUSTRY: return Industry.GetName(location.industry_id);
		case Opportunity.LT_TOWN: return Town.GetName(location.town_id);
		default: throw("Unknown destination type");
	}
}

function Opportunity::GetDestinationTown(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");

	local location = opportunities.rawget(opportunity_id).destination;
	if(location.type != Opportunity.LT_TOWN) throw("Unknown destination type");
	return location.town_id;
}

function Opportunity::GetAirportType(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)) throw("Opportunity not exists");
	return opportunities.rawget(opportunity_id).airport_type;
}

function Opportunity::CreateTown(town_id, cargo_id, vehicle_type){
	if(Opportunity.towns.HasItem(town_id)) return 0;

	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});

	local id = Storage.ValueExists("opportunity.increment") ? Storage.GetValue("opportunity.increment") : Storage.SetValue("opportunity.increment", 0);
	Storage.SetValue("opportunity.increment", id + 1);

	opportunities.rawset(id, {
		id = id,
		vehicle_type = vehicle_type,
		cargo_id = cargo_id,
		source = {
			type = Opportunity.LT_TOWN,
			town_id = town_id
		},
		destination = null,
		engine_id = null,
		price = 0,
		minimum_price = 0,
		monthly_profit = 0,
		buildable = 0,
		created = AIDate.GetCurrentDate()
	});
	return id;
}



function Opportunity::Count(){
	return Opportunity.GetCount();
}

function Opportunity::Get(opportunity_id){
	local opportunities = Storage.ValueExists("opportunities") ? Storage.GetValue("opportunities") : Storage.SetValue("opportunities", {});
	if(!opportunities.rawin(opportunity_id)){
		return null;
	}
	return opportunities.rawget(opportunity_id);
}