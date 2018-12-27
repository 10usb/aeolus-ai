class CreatePersonality extends Task {
}

function CreatePersonality::GetName(){
    return "CreatePersonality"
}

function CreatePersonality::Run(){
    this.SetName();
	this.PersonalityTraits();
    this.BuildHQ();
    
    
    this.GetParent().EnqueueTask(FindOpportunities());
	// // Add some initial tasks
	// this.GetParent()
    //     .EnqueueTask(RepayLoad())
    //     .EnqueueTask(BuildOpportunities())
    //     .EnqueueTask(FindOpportunities())
    //     .EnqueueTask(AirStationManager())
    //     .EnqueueTask(AircraftManager());

    return false;
}

function CreatePersonality::SetName(){
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
	}while(!Company.SetName(name + postfixes[AIBase.RandRange(postfixes.len())]));
	Company.SetPresidentName(initials[AIBase.RandRange(initials.len())] + ". " + name);

	Log.Info("I'm from the house of '" + name + "' and you'll will bow down before me!");
}

function CreatePersonality::PersonalityTraits(){
	local preferance = Preference("preferance.personalitytraits");
	preferance.Init(PersonalityTraitList());

	foreach(id, value in preferance.GetValues()){
		Log.Info(value + " => " + PersonalityTrait.GetName(id));
	}
}

function CreatePersonality::BuildHQ(){

}