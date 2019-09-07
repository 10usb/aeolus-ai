class FindOpportunities_PassengerPlanes extends Task {
}

function FindOpportunities_PassengerPlanes::GetName(){
    return  "FindOpportunities_PassengerPlanes";
}

function FindOpportunities_PassengerPlanes::Run(){
    Log.Info("Searching for passenger plane opportunities");

    local cargo_id = Cargo.GetPassengerId();
    // for each airport type
    //     get list of supported engines
    //     for each engine
    //         calc annual profit of engine
    //         calc minimum amount of engines needed to support airport type
    //         calc minimum capacity of cargo needed in city
    //         calc max capacity
    //         calc max annual profit
    //         add calc info to list
    local infos = AirportEngineMatrix(cargo_id).ToArray();
    //Log.Dump(infos);

    // for each town
    //     for each airport engine pair
    //         test if town has enough minimum capacity
    //         calc max investment given a budget limit
    //         calc annual profit for that investment
    //         add/update town opportunity
    local money = Finance.GetAvailableMoney() + Finance.GetMonthlyProfit() * 6;

    local towns = AITownList();
	towns.Valuate(Town.GetAvailableCargo, cargo_id);

    foreach(town_id, available in towns){
        local bestInfo = null;
        local bestRating = null;

        foreach(info in infos){
            if(available < info.minCapacity) continue;
            if(money < info.minInvestment * 1.2) continue;

            local price = Airport.GetPrice(info.airport_type);

            local capacityForCount = Math.floor(available * 60.0 / info.oneCapacity);
            local moneyForCount = Math.floor((money - price) / info.extraInvestment);
            local engineCount = Math.min(info.maxEngines, Math.min(capacityForCount, moneyForCount));

            local totalProfit = engineCount * info.profit - info.maintance;
            local totalInvestment = info.minInvestment + info.extraInvestment * (engineCount - info.minEngines);
            local years = totalInvestment.tofloat() / totalProfit;

            if(bestInfo == null || years < bestRating){
                bestInfo = info
                bestRating = years;
            }
        }
        if(bestInfo != null){
            //Log.Info("Town: " + Town.GetName(town_id) + " => " + Town.GetPopulation(town_id) + " => " + Engine.GetName(bestInfo.engine_id) + " => " + Airport.GetName(bestInfo.airport_type) + " (" + bestRating + ")");
        }
    }


    // select top 10 most profitable towns within budget limit




    // - Make a list of best plane engines for each range given 100 days of travel
    // - Find city engine pair with capacity to support maintanance of airport (some idjit
    //   set the default maintanance setting to 0)


    // - Test if airport supported by engine type can be build with enough houses that are
    //   not in range of other stations


    // - Select best 3


    // - Find destinations
    //   - Find stations in reach with over capacity of planes
    //   - Find stations in reach with over capacity of cargo
    //   - Find town with enough capacity to support the shared maintanance of the airports




    // Go into a sleep while this task is destroyed
    this.GetParent().Sleep(270);
    return false;
}