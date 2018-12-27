class PersonalityTraitList extends AIList {
	constructor(){
        ::AIList.constructor();
        
        if(Controller.GetSetting("use_air") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_AIR)){
            AddItem(PersonalityTrait.PT_PASSENGER_PLANES, 0);
            AddItem(PersonalityTrait.PT_MAIL_PLANES, 0);
            AddItem(PersonalityTrait.PT_PASSENGER_HELICOPTERS, 0);
        }
        
        if(Controller.GetSetting("use_road") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_ROAD)){
            AddItem(PersonalityTrait.PT_PASSENGER_BUSSES_TOWN, 0);
            AddItem(PersonalityTrait.PT_PASSENGER_BUSSES_INDUSTRY, 0);
            AddItem(PersonalityTrait.PT_MAIL_TRUCKS, 0);
            AddItem(PersonalityTrait.PT_FRAIGHT_TRUCKS, 0);
            AddItem(PersonalityTrait.PT_FRAIGHT_TRUCKS_HIJACK, 0);
            AddItem(PersonalityTrait.PT_FRAIGHT_TRUCKS_TOWN, 0);
        }
        
        if(Controller.GetSetting("use_rail") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_RAIL)){
            AddItem(PersonalityTrait.PT_PASSENGER_TRAINS, 0);
            AddItem(PersonalityTrait.PT_FRAIGHT_TRAINS, 0);
            AddItem(PersonalityTrait.PT_FRAIGHT_TRAINS_TOWN, 0);
        }
        
        if(Controller.GetSetting("use_water") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_WATER)){
            AddItem(PersonalityTrait.PT_FERRIES_TOWN, 0);
            AddItem(PersonalityTrait.PT_FERRIES_INDUSTRY, 0);
            AddItem(PersonalityTrait.PT_OILTANKER, 0);
            AddItem(PersonalityTrait.PT_CARGOSHIP_INDUSTRY, 0);
            AddItem(PersonalityTrait.PT_CARGOSHIP_TOWN, 0);
        }
	}
}