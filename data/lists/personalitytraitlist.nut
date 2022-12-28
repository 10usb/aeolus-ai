class PersonalityTraitList extends AIList {
	constructor(){
        ::AIList.constructor();
        
        if(Controller.GetSetting("use_air") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_AIR)){
            //AddItem(PersonalityTrait.PT_INTER_CITY | Vehicle.VT_AIR, 0);
            //AddItem(PersonalityTrait.PT_COMUTE | Vehicle.VT_AIR, 0);
        }
        
        if(Controller.GetSetting("use_road") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_ROAD)){
            AddItem(PersonalityTrait.PT_INNER_CITY | Vehicle.VT_ROAD, 0);
            //AddItem(PersonalityTrait.PT_INTER_CITY | Vehicle.VT_ROAD, 0);
        }
        
        if(Controller.GetSetting("use_rail") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_RAIL)){
            //AddItem(PersonalityTrait.PT_INTER_CITY | Vehicle.VT_RAIL, 0);
            //AddItem(PersonalityTrait.PT_FREIGHT | Vehicle.VT_RAIL, 0);
            //AddItem(PersonalityTrait.PT_RETAIL | Vehicle.VT_RAIL, 0);
            //AddItem(PersonalityTrait.PT_COMUTE | Vehicle.VT_RAIL, 0);
        }
        
        if(Controller.GetSetting("use_water") > 0 && !AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_WATER)){
            //AddItem(PersonalityTrait.PT_INTER_CITY | Vehicle.VT_WATER, 0);
            //AddItem(PersonalityTrait.PT_FREIGHT | Vehicle.VT_WATER, 0);
            //AddItem(PersonalityTrait.PT_RETAIL | Vehicle.VT_WATER, 0);
            //AddItem(PersonalityTrait.PT_COMUTE | Vehicle.VT_WATER, 0);
        }
	}
}