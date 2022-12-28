/**
 * This task only tries to connect busses and post-trucks
 * within the borders of a city
 */
class Road_FindInnerCity extends Task {
    cargo_preference = null;

	constructor(){
	}

    function GetName(){
        return "Road_FindInnerCity";
    }

    function Run(){
        // - Get favored cargo for inner city (passenger or mail)
        PrepareCargo();
        local cargo_id = cargo_preference.GetFavored();
        Log.Info("Finding inner city oppertunities for " + Cargo.GetName(cargo_id));

        // - Pick town based on stats
        local towns = AITownList();
        towns.Valuate(Town.GetAvailableCargo, cargo_id);
        
        Log.Info("Towns");
        towns.Sort(List.SORT_BY_VALUE, false);
        foreach(id, value in towns){
            if(Town.IsCity(id)){
                Log.Info(" - " + value + " => " + Town.GetName(id) + " (city)");
            }else{
                Log.Info(" - " + value + " => " + Town.GetName(id));
            }
        }

        // - How many stations can be fitted
        // - Calculcate base cost/profit + variable cost/profit
        // - Does it fit the minimum?
        // - Sumbit oppertunity
	    return this.Sleep(500);
    }

    function PrepareCargo(){
        if(cargo_preference == null){
            cargo_preference = Preference("preferance.cargo.road.innercity");

            if(!cargo_preference.IsLoaded()){
                local values = Company.GetCargoPreference().GetValues();

                local cargos = List();
                cargos.AddItem(Cargo.GetPassengerId(), values.GetValue(Cargo.GetPassengerId()));
                cargos.AddItem(Cargo.GetMailId(), values.GetValue(Cargo.GetMailId()));

                cargo_preference.Init(cargos, false);
            }

            Log.Info("Cargo Inner City");
            foreach(id, value in cargo_preference.GetValues()){
                Log.Info(" - " + value + " => " + Cargo.GetName(id));
            }
        }
    }
}