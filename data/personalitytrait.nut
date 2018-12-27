class PersonalityTrait {
	static PT_INVALID = 0;
	static PT_PASSENGER_PLANES = 1;
	static PT_MAIL_PLANES = 2;
	static PT_PASSENGER_HELICOPTERS = 3;
	static PT_PASSENGER_BUSSES_TOWN = 4;
	static PT_PASSENGER_BUSSES_INDUSTRY = 5;
	static PT_MAIL_TRUCKS = 6;
	static PT_FRAIGHT_TRUCKS = 7;
	static PT_FRAIGHT_TRUCKS_HIJACK = 8;
	static PT_FRAIGHT_TRUCKS_TOWN = 9;
	static PT_PASSENGER_TRAINS = 10;
	static PT_FRAIGHT_TRAINS = 11;
	static PT_FRAIGHT_TRAINS_TOWN = 12;
	static PT_FERRIES_TOWN = 13;
	static PT_FERRIES_INDUSTRY = 14;
	static PT_OILTANKER = 15;
	static PT_CARGOSHIP_INDUSTRY = 16;
	static PT_CARGOSHIP_TOWN = 17;
}

function PersonalityTrait::GetName(personality_trait){
	switch(personality_trait){
		case PersonalityTrait.PT_INVALID: return "Invalid";
		case PersonalityTrait.PT_PASSENGER_PLANES: return "Passenger Planes (Town to Town)";
		case PersonalityTrait.PT_MAIL_PLANES: return "Mail Planes (Town to Town)";
		case PersonalityTrait.PT_PASSENGER_HELICOPTERS: return "Passenger Helicopters (Industry to Town)";
		case PersonalityTrait.PT_PASSENGER_BUSSES_TOWN: return "Passenger Buses (Town to Town)";
		case PersonalityTrait.PT_PASSENGER_BUSSES_INDUSTRY: return "Passenger Buses (Industry to Town)";
		case PersonalityTrait.PT_MAIL_TRUCKS: return "Mail Buses (Town to Town)";
		case PersonalityTrait.PT_FRAIGHT_TRUCKS: return "Fraight Trucks (Industry to Industry)";
		case PersonalityTrait.PT_FRAIGHT_TRUCKS_HIJACK: return "Fraight Trucks (Industry to Industry, Hijack routes)";
		case PersonalityTrait.PT_FRAIGHT_TRUCKS_TOWN: return "Fraight Trucks (Industry to Town)";
		case PersonalityTrait.PT_PASSENGER_TRAINS: return "Passenger & Mail Trains (Town to Town)";
		case PersonalityTrait.PT_FRAIGHT_TRAINS: return "Fraight Trains (Industry to Industry)";
		case PersonalityTrait.PT_FRAIGHT_TRAINS_TOWN: return "Fraight Trains (Industry to Town)";
		case PersonalityTrait.PT_FERRIES_TOWN: return "Farries (Town to Town)";
		case PersonalityTrait.PT_FERRIES_INDUSTRY: return "Farries (Industry to Town)";
		case PersonalityTrait.PT_OILTANKER: return "Oiltanker (Industry to Industry)";
		case PersonalityTrait.PT_CARGOSHIP_INDUSTRY: return "Cargoship (Industry to Industry)";
		case PersonalityTrait.PT_CARGOSHIP_TOWN: return "Cargoship (Industry to Town)";
		default: return "Unkown (#" + personality_trait + ")"
	}
}