class CreatePersonality extends Task {

    function GetName(){
    	return "CreatePersonality"
    }

    function Run(){
		this.SetName();
		this.PersonalityTraits();
		this.BuildHQ();
		
		// Find something todo
		local budget_id = Company.GetInvestmentBudget();
		Budget.Add(budget_id, Finance.GetAvailableMoney() * 0.9);

		this.GetParent().EnqueueTask(FindOpportunities());
		this.GetParent().EnqueueTask(RepayLoan());
		this.GetParent().EnqueueTask(Tasks_Finance());
		
		return false;
	}

	function SetName(){
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

	function PersonalityTraits(){
		PersonalityTrait.preferance.Init(PersonalityTraitList());

		Log.Info("PersonalityTraits");
		foreach(id, value in PersonalityTrait.preferance.GetValues()){
			Log.Info(" - " + value + " => " + PersonalityTrait.GetName(id));
		}

		Log.Info("Cargo");
		foreach(id, value in Company.GetCargoPreference().GetValues()){
			Log.Info(" - " + value + " => " + Cargo.GetName(id));
		}
	}

	function BuildHQ(){
		local towns = AITownList();
		towns.Valuate(Town.IsCity);
		towns.KeepValue(1);

		towns.Valuate(Town.GetPopulation);
		local town_id = Lists.RandPriority(towns);

		Log.Info("Hometown: " + Town.GetName(town_id) + " (" + Town.GetPopulation(town_id) + ")");

		local tiles = Town.GetTiles(town_id, true, 2);
		tiles.Valuate(Tile.IsBuildableRectangle, 2, 2);
		tiles.KeepValue(1);
		tiles.Valuate(CreatePersonality.RoadAccessHQ);
		tiles.KeepAboveValue(0);
		tiles.Sort(AIList.SORT_BY_VALUE, false);

		//tiles.Valuate(Tile.GetDistanceSquareToTile, Town.GetLocation(town_id));
		//tiles.Sort(AIList.SORT_BY_VALUE, true);

		local tile;
		do {
			tile = tiles.Begin();
			tiles.RemoveTop(1);

			local matrix = MapMatrix();
			matrix.AddRectangle(tile, 2, 2);
			if(!matrix.MakeLevel()) continue;
		}while(!Company.BuildCompanyHQ(tile) && tiles.Count())
	}

	function RoadAccessHQ(tile){
		local tiles = AITileList();
		tiles.AddRectangle(Tile.GetTranslatedIndex(tile, 0, -1), Tile.GetTranslatedIndex(tile, 1, 2));
		tiles.AddRectangle(Tile.GetTranslatedIndex(tile, -1, 0), Tile.GetTranslatedIndex(tile, 2, 1));
		tiles.Valuate(AIRoad.IsRoadTile);
		return Lists.GetSum(tiles);
	}
}