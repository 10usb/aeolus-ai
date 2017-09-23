class Company extends AICompany {
	static global = {
		cargo = null
		vehicle = null
	};
}


function Company::Init(){
	local initials	= [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" ];
	local names		= [ "Aphrodite", "Apollo", "Aresv", "Artemis", "Athena", "Demeter", "Dionysus", "Hades", "Hephaestus", "Hera", "Hermes", "Hestia",
						"Poseidon", "Zeus", "Aether", "Ananke", "Erebos", "Gaia", "Hemera", "Chaos", "Chronos", "Nesoi", "Nyx", "Ouranos", "Ourea",
						"Phanes", "Pontus", "Tartarus", "Thalassa", "Hyperion", "Iapetus", "Coeus", "Crius", "Cronus", "Mnemosyne", "Oceanus", "Phoebe",
						"Rhea", "Tethys", "Theia", "Themis", "Asteria", "Astraeus", "Atlas", "Aura", "Dione", "Eos", "Epimetheus", "Eurybia", "Eurynome",
						"Helios", "Clymene", "Lelantos", "Leto", "Menoetius", "Metis", "Ophion", "Pallas", "Perses", "Prometheus", "Selene", "Styx" ];
	local postfixes	= [ "", "", "", "", "", "", " Ltd.", " Corp.", " Inc.", " Ltd. Co.", " GmbH", " & Co", " V.O.F.", " B.V." ]
	local name		= "Unknown";
	do {
		name = names[AIBase.RandRange(names.len())];
	}while(!AICompany.SetName(name + postfixes[AIBase.RandRange(postfixes.len())]));
	AICompany.SetPresidentName(initials[AIBase.RandRange(initials.len())] + ". " + name);

	AILog.Info("I'm from the house of '" + name + "' and you'll will bow down before me!");
	AILog.Info("Supply me " + Cargo.GetName(Company.GetCargoPreference().GetFavored()) + "!!! I would like that, please...");



	AILog.Info("Tuning in on some great music while running my company");
	switch(Company.GetVehicleTypePreference().GetFavored()){
		case AIVehicle.VT_RAIL: AILog.Info(" - Great Train Robbery by Black Uhuru"); break;
		case AIVehicle.VT_ROAD: AILog.Info(" - Road Tripin' by Red Hot Chili Peppers"); break;
		case AIVehicle.VT_WATER: AILog.Info(" - I'm on a Boat by The Lonely Island (feat. T-Pain)"); break;
		case AIVehicle.VT_AIR: AILog.Info(" - Flying High by Captain Hollywood Project"); break;
	}
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
			if(Aeolus.GetSetting("use_air") > 0){
				vehicle_types.AddItem(AIVehicle.VT_AIR, 0);
			}
			if(Aeolus.GetSetting("use_rail") > 0){
				vehicle_types.AddItem(AIVehicle.VT_RAIL, 0);
			}
			if(Aeolus.GetSetting("use_road") > 0){
				vehicle_types.AddItem(AIVehicle.VT_ROAD, 0);
			}
			if(Aeolus.GetSetting("use_water") > 0){
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