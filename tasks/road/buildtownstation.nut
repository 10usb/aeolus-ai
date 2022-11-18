/**
 * This task tries build a bus or truck station in a town
 * with a reasonable distance to other stations of same type.
 */
 class Road_BuildTownStation extends Task {
	static DETECT_OTHERS		= 0;
    static FIND_POTENTIAL       = 1;
	static BUILD_STATION        = 2;
	static ENSURE_DEPOT         = 3;

	state = 0;
    town_id = null;
    cargo_id = null;

	constructor(town_id, cargo_id){
        this.town_id = town_id
        this.cargo_id = cargo_cargo_idtype;
		this.state = DETECT_OTHERS;
	}

    function GetName(){
        return "Road_BuildTownStation"
    }

    function Run(){
        switch(state){
            case DETECT_OTHERS: return DetectOthers();
            case FIND_POTENTIAL: return FindPotential();
            case BUILD_STATION: return BuildStation();
            case ENSURE_DEPOT: return EnsureDepot();
        }

        return false;
    }

    /**
     Finds other similar bus/truck stations tiles
    */
    function DetectOthers(){

    }

    /**
     Find tiles that support a minimum production and/or acceptance
     of the specified cargo. And are of reasonable distance to
     other stations
    */
    function FindPotential(){

    }

    /**
     Attempt to build a station on one of the potential tiles.
    */
    function BuildStation(){

    }

    /**
     Tries to find a spot for a depot to build. And checks if there
     isn't one closer by.
    */
    function EnsureDepot(){

    }
}