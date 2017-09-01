class Industry {
	static list = {};

	id = null;
	station_build = null;

	constructor(id){
		this.id = id;
		this.station_build = null;
	}
}

function Industry::Get(id){
	if(!Industry.list.rawin(id)){
		Industry.list.rawset(id, Industry(id));
	}
	return Industry.list.rawget(id);
}
function Industry::CanBuildStation(industry_id){
	local industry = Industry.Get(industry_id);
	if(industry.station_build==null) return 1;
	if((AIDate.GetCurrentDate() - industry.station_build) > 200) return 1;
	return 0;
}

function Industry::GetCargoIncome(industry_id, distance, days){
	local income = 0;
	foreach(cargo_id in AICargoList_IndustryProducing(industry_id)){
		income+= AICargo.GetCargoIncome(cargo_id, distance, days) * (AIIndustry.GetLastMonthProduction(industry_id, cargo_id) - AIIndustry.GetLastMonthTransported(industry_id, cargo_id));
	}
	return income;
}

function Industry::GetAvailableCargo(industry_id, cargo_id){
	if(typeof cargo_id == "array"){
		local total = 0;
		foreach(id in cargo_id){
			total+= AIIndustry.GetLastMonthProduction(industry_id, id) - AIIndustry.GetLastMonthTransported(industry_id, id);
		}
		return total;
	}else{
		return AIIndustry.GetLastMonthProduction(industry_id, cargo_id) - AIIndustry.GetLastMonthTransported(industry_id, cargo_id);
	}
}