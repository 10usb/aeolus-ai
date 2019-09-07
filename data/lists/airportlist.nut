class AirportList extends AIList {
	constructor(isAvailable){
        ::AIList.constructor();
        AddItem(Airport.AT_SMALL, 0);
        AddItem(Airport.AT_LARGE, 0);
        AddItem(Airport.AT_METROPOLITAN, 0);
        AddItem(Airport.AT_INTERNATIONAL, 0);
        AddItem(Airport.AT_COMMUTER, 0);
        AddItem(Airport.AT_INTERCON, 0);
        AddItem(Airport.AT_HELIPORT, 0);
        AddItem(Airport.AT_HELISTATION, 0);
        AddItem(Airport.AT_HELIDEPOT, 0);

        if(isAvailable){
            Valuate(Airport.IsValidAirportType);
            KeepValue(1);
            Valuate(Airport.IsAirportInformationAvailable);
            KeepValue(1);
        }
	}
}