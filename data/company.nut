class Company {
	static global = {
		cargo = {
			preference = null,
			rating = null,
			favor = null
		}
	};
}


function Company::Init(){
	local initials = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	local names = ["Aphrodite", "Apollo", "Aresv", "Artemis", "Athena", "Demeter", "Dionysus", "Hades", "Hephaestus", "Hera", "Hermes", "Hestia", "Poseidon", "Zeus", "Aether", "Ananke", "Erebos", "Gaia", "Hemera", "Chaos", "Chronos", "The�Nesoi", "Nyx", "Ouranos", "The�Ourea", "Phanes", "Pontus", "Tartarus", "Thalassa", "Hyperion", "Iapetus", "Coeus", "Crius", "Cronus", "Mnemosyne", "Oceanus", "Phoebe", "Rhea", "Tethys", "Theia", "Themis", "Asteria", "Astraeus", "Atlas", "Aura", "Dione", "Eos", "Epimetheus", "Eurybia", "Eurynome", "Helios", "Clymene", "Lelantos", "Leto", "Menoetius", "Metis", "Ophion", "Pallas", "Perses", "Prometheus", "Selene", "Styx"];
	local index = 0;
	local index2 = 0;
	do {
		index = AIBase.RandRange(names.len());
	}while(!AICompany.SetName(names[index]));

	index2 = AIBase.RandRange(initials.len());
	AICompany.SetPresidentName(initials.slice(index2, index2 + 1) + ". " + names[index]);

	local cargos = AICargoList();
	cargos.Valuate(List.RandRangeItem, 1, 1000);
	cargos.Sort(AIList.SORT_BY_VALUE, false);
	cargos.Valuate(List.GetNormalizeValueTo, cargos, List.GetSum(cargos), 10000);
	cargos.SetValue(cargos.Begin(), cargos.GetValue(cargos.Begin()) + 10000 - List.GetSum(cargos));

	foreach(cargo_id, value in cargos){
		AILog.Info(AICargo.GetCargoLabel(cargo_id) + ":" + value);
	}

	Company.global.cargo.preference = cargos;
	Company.global.cargo.rating = AIList();
	Company.global.cargo.rating.AddList(Company.global.cargo.preference);
	Company.global.cargo.rating.Valuate(List.SetValue, 0);
	Company.global.cargo.favor	= AIList();
	Company.global.cargo.favor.AddList(Company.global.cargo.preference);
}

function Company::GetFavoredCargo(){
	return Company.global.cargo.favor.Begin();
}

function Company::DecreaseCargoFavor(cargo_id){
	foreach(id, value in Company.global.cargo.preference){
		if(id!=cargo_id){
			Company.global.cargo.rating.SetValue(id, Company.global.cargo.rating.GetValue(id) + value / 10);
		}
	}

	Company.global.cargo.rating.SetValue(cargo_id, Company.global.cargo.rating.GetValue(cargo_id) - List.GetSum(Company.global.cargo.rating));


	foreach(id, value in Company.global.cargo.favor){
		Company.global.cargo.favor.SetValue(id, Company.global.cargo.preference.GetValue(id) + Company.global.cargo.rating.GetValue(id));
	}
	Company.global.cargo.favor.Sort(AIList.SORT_BY_VALUE, false);

	AILog.Info("Decreasing favor for " + AICargo.GetCargoLabel(cargo_id));
}

function Company::GetFavoredVehicleType(){
	return AIVehicle.VT_RAIL;
}