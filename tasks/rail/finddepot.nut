/**
 * This task will performs a search for a depot in either traveling direction
 * towards or from the station. If no depot can be found it will return the
 * best place to build a depot.
 */
 class RailFindDepot extends Task {
    station_id = null;
    placement = null;

	constructor(station_id, placement){
        this.station_id = station_id;
        this.placement = placement;
	}

    function GetName(){
        return "RailFindDepot"
    }

    function GetLocation(){
        return MapEntry(index, origin);
    }

    function Run(){
        return false;
    }
}