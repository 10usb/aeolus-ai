class PersonalityTrait {
	static PT_INVALID = 0;
	// Inner city (trucks)
	static PT_INNER_CITY = 4;
	// Inter city (all)
	static PT_INTER_CITY = 8;
	// Industry to industry (-planes)
	static PT_FREIGHT = 12;
	// Industry to town (-planes)
	static PT_RETAIL = 16;
	// Town to industry (all)
	static PT_COMUTE = 20;
	
    static preferance = Preference("preferance.personalitytraits");
}

function PersonalityTrait::GetName(personality_trait){
	local type = "";

	switch(personality_trait & 3){
		case Vehicle.VT_RAIL: type = "Trains"; break;
		case Vehicle.VT_ROAD: type = "Truck"; break;
		case Vehicle.VT_AIR: type = "Planes"; break;
		case Vehicle.VT_WATER: type = "Ships"; break;
	}

	switch(personality_trait & ~3){
		case PersonalityTrait.PT_INVALID: return "Invalid " + type;
		case PersonalityTrait.PT_INNER_CITY: return type + " inner city";
		case PersonalityTrait.PT_INTER_CITY: return type + " inter city";
		case PersonalityTrait.PT_FREIGHT: return type + " freight";
		case PersonalityTrait.PT_RETAIL: return type + " retail";
		case PersonalityTrait.PT_COMUTE: return type + " comute";
		default: return "Unkown (#" + personality_trait + ")"
	}
}

function PersonalityTrait::GetFavored(){
    return PersonalityTrait.preferance.GetFavored();
}

function PersonalityTrait::DecreaseFavor(personality_trait){
    return PersonalityTrait.preferance.DecreaseFavor(personality_trait);
}