class Company {
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

	Company.global.cargo = Preference(AICargoList());

	AILog.Info("Supply me " + AICargo.GetCargoLabel(Company.global.cargo.GetFavored()) + "!!! I would like that, please...");

	local vehicle_types = AIList();
	vehicle_types.AddItem(AIVehicle.VT_RAIL, 0);
	//vehicle_types.AddItem(AIVehicle.VT_ROAD, 0);
	//vehicle_types.AddItem(AIVehicle.VT_WATER, 0);
	vehicle_types.AddItem(AIVehicle.VT_AIR, 0);

	Company.global.vehicle = Preference(vehicle_types);

	AILog.Info("Tuning in on some great music while running my company");
	switch(Company.global.vehicle.GetFavored()){
		case AIVehicle.VT_RAIL: AILog.Info(" - Great Train Robbery by Black Uhuru"); break;
		case AIVehicle.VT_ROAD: AILog.Info(" - Road Tripin' by Red Hot Chili Peppers"); break;
		case AIVehicle.VT_WATER: AILog.Info(" - I'm on a Boat by The Lonely Island (feat. T-Pain)"); break;
		case AIVehicle.VT_AIR: AILog.Info(" - Flying High by Captain Hollywood Project"); break;
	}
}

function Company::GetFavoredCargo(){
	return Company.global.cargo.GetFavored();
}

function Company::DecreaseCargoFavor(cargo_id){
	AILog.Info("Decreasing favor for " + AICargo.GetCargoLabel(cargo_id));
	return Company.global.cargo.DecreaseFavor(cargo_id);

}

function Company::GetFavoredVehicleType(){
	return Company.global.vehicle.GetFavored();
}

function Company::DecreaseVehicleTypeFavor(vehicle_type){
	switch(Company.global.vehicle.GetFavored()){
		case AIVehicle.VT_RAIL: AILog.Info("Decreasing favor for Great Train Robbery by Black Uhuru"); break;
		case AIVehicle.VT_ROAD: AILog.Info("Decreasing favor for Road Tripin' by Red Hot Chili Peppers"); break;
		case AIVehicle.VT_WATER: AILog.Info("Decreasing favor for I'm on a Boat by The Lonely Island (feat. T-Pain)"); break;
		case AIVehicle.VT_AIR: AILog.Info("Decreasing favor for Flying High by Captain Hollywood Project"); break;
	}
	return Company.global.vehicle.DecreaseFavor(vehicle_type);
}