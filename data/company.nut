class Company extends AICompany {
}

function Company::GetCargoPreference(){
	local preferance = null;
	
	if(!Cache.ValueExists("preferance.cargo")){
		preferance = Cache.SetValue("preferance.cargo", Preference("preferance.cargo"));
		if(!preferance.IsLoaded()){
			preferance.Init(AICargoList());
		}
	}

	return Cache.GetValue("preferance.cargo");
}

function Company::GetFavoredCargo(){
	return Company.GetCargoPreference().GetFavored();
}

function Company::DecreaseCargoFavor(cargo_id){
	//AILog.Info("Decreasing favor for " + Cargo.GetName(cargo_id));
	return Company.GetCargoPreference().DecreaseFavor(cargo_id);

}

function Company::GetVehicleTypePreference(){
	local preferance = null;

	if(!Cache.ValueExists("preferance.vehicle_types")){
		preferance = Cache.SetValue("preferance.vehicle_types", Preference("preferance.vehicle_types"));
		if(!preferance.IsLoaded()){
			local vehicle_types = AIList();
			if(Controller.GetSetting("use_air") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_AIR)){
				vehicle_types.AddItem(AIVehicle.VT_AIR, 0);
			}
			if(Controller.GetSetting("use_rail") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_RAIL)){
				vehicle_types.AddItem(AIVehicle.VT_RAIL, 0);
			}
			if(Controller.GetSetting("use_road") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_ROAD)){
				vehicle_types.AddItem(AIVehicle.VT_ROAD, 0);
			}
			if(Controller.GetSetting("use_water") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_WATER)){
				vehicle_types.AddItem(AIVehicle.VT_WATER, 0);
			}
			preferance.Init(vehicle_types);
		}
	}

	return Cache.GetValue("preferance.vehicle_types");
}

function Company::GetFavoredVehicleType(){
	return Company.GetVehicleTypePreference().GetFavored();
}

function Company::DecreaseVehicleTypeFavor(vehicle_type){
	/*
	switch(Company.GetVehicleTypePreference().GetFavored()){
		case AIVehicle.VT_RAIL: AILog.Info("Decreasing favor for Great Train Robbery by Black Uhuru"); break;
		case AIVehicle.VT_ROAD: AILog.Info("Decreasing favor for Road Tripin' by Red Hot Chili Peppers"); break;
		case AIVehicle.VT_WATER: AILog.Info("Decreasing favor for I'm on a Boat by The Lonely Island (feat. T-Pain)"); break;
		case AIVehicle.VT_AIR: AILog.Info("Decreasing favor for Flying High by Captain Hollywood Project"); break;
	}*/
	return Company.GetVehicleTypePreference().DecreaseFavor(vehicle_type);
}

function Company::GetTownPreference(){
	local preferance = null;

	if(!Cache.ValueExists("preferance.towns")){
		preferance = Cache.SetValue("preferance.towns", Preference("preferance.towns"));
		if(!preferance.IsLoaded()){
			local towns = AITownList();
			towns.Valuate(Town.GetPopulation);
			preferance.Init(towns);
		}
	}

	return Cache.GetValue("preferance.towns");
}

function Company::GetInvestmentBudget(){
	local budget_id = Storage.ValueExists("company.investment") ? Storage.GetValue("company.investment") : Storage.SetValue("company.investment", 0)
	
	if(!Budget.IsValidBudget(budget_id)){
		budget_id = Budget.CreateBudget("Company Investment");
		Storage.SetValue("company.investment", budget_id);
	}

	return budget_id;
}