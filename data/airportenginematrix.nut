class AirportEngineMatrix {
    data = null;

    constructor(cargo_id){
        local name = "airportenginematrix." + cargo_id;
        if(!Storage.ValueExists(name)) AirportEngineMatrix.Refresh(cargo_id);
        data = Storage.GetValue(name);
    }
}

function AirportEngineMatrix::ToArray(){
    local infos = [];

    foreach(entry in data.info){
        foreach(info in entry){
            infos.push(info);
        }
    }

    return infos;
}

function AirportEngineMatrix::Refresh(cargo_id){
	local availableEngines = AIEngineList(Vehicle.VT_AIR);
	availableEngines.Valuate(Engine.IsBuildable);
	availableEngines.KeepValue(1);
    availableEngines.Valuate(Engine.GetPlaneType);
	availableEngines.RemoveValue(Airport.PT_HELICOPTER);
    availableEngines.Valuate(Engine.CanRefitCargo, cargo_id);
	availableEngines.KeepValue(1);

    local data = {
        created = AIDate.GetCurrentDate(),
        info = {}
    };

    foreach(airport_type, dummy in AirportList(true)){
        local entry = {};

        local engines = AIList();
        engines.AddList(availableEngines);
        engines.Valuate(Engine.CanEngineLand, airport_type);
        engines.KeepValue(1);

        foreach(engine_id, dummy in engines){
            local distance = Engine.GetEstimatedDistance(engine_id, 60, 0.95);
            local capacity = AIEngine.GetCapacity(engine_id);
            local income = Math.floor(Cargo.GetCargoIncome(cargo_id, distance, 60) * capacity * 3.65);
            local cost = Engine.GetRunningCost(engine_id);
            local profit = income - cost;
            local airport_cost = Airport.GetMaintenanceCost(airport_type) * 12;
            local minEngines = max(1, Math.ceil(airport_cost / (profit / 2.0)));
            local maxEngines = Math.floor(60.0 * 2 / Airport.GetDaysBetweenAcceptPlane(airport_type));
            
            local info = {
                airport_type = airport_type,
                engine_id = engine_id,
                capacity = capacity,
                income = income,
                runningCost = cost,
                profit = profit,
                minEngines = minEngines,
                maxEngines = maxEngines,
                maintance = airport_cost,
                minInvestment = Airport.GetPrice(airport_type) + Engine.GetPrice(engine_id) * minEngines
                extraInvestment = Engine.GetPrice(engine_id)
                minCapacity = Math.ceil(capacity / 3.94520547945205 * minEngines),
                maxCapacity = Math.floor(capacity / 3.94520547945205 * maxEngines),
                oneCapacity = Math.round(capacity / 0.0394520547945205),
            };

            entry.rawset(engine_id, info);
        }

        if(entry.len()) data.info.rawset(airport_type, entry);
    }

    Storage.SetValue("airportenginematrix." + cargo_id, data);
}