require("manager.nut");
require("plane.nut");
require("port.nut");

class AirController {
	static _ = {};
}

function AirController::GetManager(){
	if(!AirController._.rawin("manager")){
		AirController._.rawset("manager", AirManager());
	}
	return AirController._.rawget("manager");
}


function AirController::GetPassengersId(){
	local cargos = AICargoList();
	cargos.Valuate(AICargo.HasCargoClass, AICargo.CC_PASSENGERS);
	if(cargos.Count() < 1) throw("No passengers cargo class");
	return cargos.Begin();
}

function AirController::FoundNewAirports(){
	if(AirController._.rawin("airport_build") && (AIDate.GetCurrentDate() - AirController._.rawget("airport_build")) < 30) return false;
	
	// Get best engine available
	local engine_id = AirPlane.FindBestPlane();
	
	local price = (AIAirport.GetPrice(AIAirport.AT_SMALL) * 2 + AIEngine.GetPrice(engine_id)) * 1.4;
	if(price > Finance.GetAvailableMoney()) return false;
	
	local towns = null;
	
	// Find initial
	towns = AITownList();
	towns.Valuate(Town.CanBuildAirport);
	towns.KeepAboveValue(0);
	towns.Valuate(Town.GetAirportCount);
	towns.KeepValue(0);
	towns.Valuate(AITown.GetPopulation);
	towns.Sort(AIList.SORT_BY_VALUE, false);
	towns.KeepTop(7);
	towns.Valuate(Town.GetAvailableCargo, AirController.GetPassengersId());
	towns.KeepAboveValue(AIEngine.GetCapacity(engine_id));
	towns.Sort(AIList.SORT_BY_VALUE, false);
	if(towns.Count()<=0) return false;
	towns.KeepTop(3);
	towns.Valuate(AIBase.RandRangeItem, towns.Count() * 3);
	
	local town_id = towns.Begin();
	
	// Find matching tound
	towns = AITownList();
	towns.Valuate(Town.CanBuildAirport);
	towns.KeepAboveValue(0);
	towns.RemoveItem(town_id);
	towns.Valuate(Town.GetDaysTravel, AITown.GetLocation(town_id), AIEngine.GetMaxSpeed(engine_id));
	towns.KeepBetweenValue(30, 80); // Optimal amount of days travel
	towns.Valuate(Town.GetAirportCount);
	towns.Sort(AIList.SORT_BY_VALUE, false);
	towns.KeepValue(0);
	towns.Valuate(Town.GetAvailableCargo, AirController.GetPassengersId());
	towns.KeepAboveValue(AIEngine.GetCapacity(engine_id) / 2);
	towns.Sort(AIList.SORT_BY_VALUE, false);
	if(towns.Count()<=0) return false;
	towns.KeepTop(3);
	towns.Valuate(AIBase.RandRangeItem, towns.Count() * 3);
	
	local other_id = towns.Begin();
	
	
	if(!Finance.GetMoney(price)) return false;
	
	local price = (AIAirport.GetPrice(AIAirport.AT_SMALL) * 2 + AIEngine.GetPrice(engine_id)) * 1.2;
	local budget = Math.min((price / 2) + (Finance.GetAvailableMoney() * 0.1), (Finance.GetAvailableMoney() - price) / 2);
	
	
	local town_tile = Town.Get(town_id).BuildAirport(AirController.GetPassengersId(), AirPlane.IsSmall(engine_id), budget);
	if(town_tile==false){
		Finance.Repay();
		return false;
	}
	
	local other_tile = Town.Get(other_id).BuildAirport(AirController.GetPassengersId(), AirPlane.IsSmall(engine_id), budget);
	if(other_tile==false){
		AIAirport.RemoveAirport(town_tile);
		Finance.Repay();
		return false;
	}
	
	AirController._.rawset("airport_build", AIDate.GetCurrentDate());

	local hanger = AIAirport.GetHangarOfAirport(town_tile);

	local vehicle = AIVehicle.BuildVehicle(hanger, engine_id);
	if (!AIVehicle.IsValidVehicle(vehicle)){
		AIAirport.RemoveAirport(town_tile);
		AIAirport.RemoveAirport(other_tile);
		Finance.Repay();
		AILog.Error("Building plane failed: " + AIError.GetLastErrorString());
		return false;
	}

	AIOrder.AppendOrder(vehicle, town_tile, AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle, other_tile, AIOrder.OF_NONE);
	AIVehicle.StartStopVehicle(vehicle);
	
	if(!Finance.GetMoney(AIEngine.GetPrice(engine_id))){
		Finance.Repay();
		return true;
	}
		
	local other_vehicle = AIVehicle.CloneVehicle(AIAirport.GetHangarOfAirport(other_tile), vehicle, false);
	if(!AIVehicle.IsValidVehicle(other_vehicle)){
		Finance.Repay();
		return true;
	}
	
	AIOrder.SkipToOrder(other_vehicle, 1);
	AIVehicle.StartStopVehicle(other_vehicle);
	
	Finance.Repay();
	return true;
}

function AirController::BuildNewPlanes(){
	local engine_id	= AirPlane.FindSmallPlane();
	if(AIBase.RandRange(2) > 0){
		local bigengine_id		= AirPlane.FindBigPlane();
		if(bigengine_id!=null){
			engine_id = bigengine_id;
		}
	}
	local small = AirPlane.IsSmall(engine_id);
	local stations = null;
	
	if(AIEngine.GetPrice(engine_id) > Finance.GetAvailableMoney()) return false;
	
	local cargos = AIList();
	foreach(cargo_id, dummy in AICargoList()){
		if(AIEngine.CanRefitCargo(engine_id, cargo_id)){
			cargos.AddItem(cargo_id, 0);
		}
	}
	cargos.Valuate(AIBase.RandRangeItem, cargos.Count() * 3);
	cargos.Sort(AIList.SORT_BY_VALUE, false);
	local cargo_id = cargos.Begin();
	
	stations = AIStationList(AIStation.STATION_AIRPORT);
	stations.Valuate(Station.GetIsFull);
	stations.KeepValue(0);
	if(small){
		stations.Valuate(AirPort.IsSmall);
		stations.KeepValue(1);
	}
	stations.Valuate(AIStation.GetCargoWaiting, cargo_id);
	stations.KeepAboveValue(AIEngine.GetCapacity(engine_id));
	
	if(stations.Count()<=0) return false;
	
	local station_id = stations.Begin();
	
	
	stations = AIStationList(AIStation.STATION_AIRPORT);
	stations.RemoveItem(station_id);
	stations.Valuate(Station.GetIsFull);
	stations.KeepValue(0);
	stations.Valuate(Station.GetDaysTravel, AITown.GetLocation(station_id), AIEngine.GetMaxSpeed(engine_id));
	stations.KeepBetweenValue(30, 80); // Optimal amount of days travel
	stations.Valuate(AIStation.GetCargoWaiting, cargo_id);
	stations.KeepAboveValue(AIEngine.GetCapacity(engine_id));
	
	if(stations.Count()<=0) return false;
	
	local other_id = stations.Begin();
	
	if(!Finance.GetMoney(AIEngine.GetPrice(engine_id))) return false;
	
	local hanger = AIAirport.GetHangarOfAirport(AIStation.GetLocation(station_id));

	local vehicle = AIVehicle.BuildVehicle(hanger, engine_id);
	if (!AIVehicle.IsValidVehicle(vehicle)){
		Finance.Repay();
		AILog.Error("Building plane failed: " + AIError.GetLastErrorString());
		return false;
	}
	
	if(AIEngine.GetCargoType(engine_id)!=cargo_id){
		AIVehicle.RefitVehicle(vehicle, cargo_id);
	}

	AIOrder.AppendOrder(vehicle, AIStation.GetLocation(station_id), AIOrder.OF_NONE);
	AIOrder.AppendOrder(vehicle, AIStation.GetLocation(other_id), AIOrder.OF_NONE);
	AIVehicle.StartStopVehicle(vehicle);
	
	Finance.Repay();
	return true;
}

function AirController::UpgradeAirports(){
	
}

function AirController::CheckPlanes(){
	local vehicles = AIVehicleList();
	vehicles.Valuate(AIVehicle.GetVehicleType);
	vehicles.KeepValue(AIVehicle.VT_AIR);
	
	local old = AIList();
	old.AddList(vehicles);
	old.Valuate(AirPlane.IsOld);
	old.KeepValue(1);
	foreach(vehicle_id, dummy in old){
		if(!AIOrder.IsGotoDepotOrder(vehicle_id, AIOrder.ORDER_CURRENT)) {
			AIVehicle.SendVehicleToDepot(vehicle_id);
		}
	}
	
	local indepot = AIList();
	indepot.AddList(vehicles);
	indepot.Valuate(AIVehicle.IsStoppedInDepot);
	indepot.KeepValue(1);
	
	foreach(vehicle_id, dummy in indepot){
		AIVehicle.SellVehicle(vehicle_id);
	}
}


