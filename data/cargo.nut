class Cargo extends AICargo {
}

function Cargo::GetName(cargo_id){
	local label = Cargo.GetCargoLabel(cargo_id);
	if(label == "PASS") return "Passengers";
	if(label == "MAIL") return "Mail";
	if(label == "GOOD") return "Goods";
	if(label == "VALU") return "Valuables";
	if(label == "LVST") return "Livestock";
	if(label == "STEL") return "Steel";
	if(label == "OIL_") return "Oil";
	if(label == "WOOD") return "Wood";
	if(label == "COAL") return "Coal";
	if(label == "COAL") return "Coal";
	if(label == "GRAI") return "Grain";
	if(label == "IORE") return "Iron Ore";
	return label;
}

function Cargo::GetWeight(cargo_id, amount){
	if(Cargo.GetCargoLabel(cargo_id) == "PASS") return amount / 20;
	if(Cargo.GetCargoLabel(cargo_id) == "MAIL") return amount / 4;
	if(Cargo.GetCargoLabel(cargo_id) == "GOOD") return amount / 2;
	if(Cargo.GetCargoLabel(cargo_id) == "VALU") return amount / 10;
	if(Cargo.GetCargoLabel(cargo_id) == "LVST") return amount / 5;
	return amount;
}

function Cargo::GetAmountWaitingAtStation(cargo_id, station_id){
	return Station.GetCargoWaiting(station_id, cargo_id);
}

function Cargo::GetPassengerId(){
	local cargos = AICargoList();
	cargos.Valuate(Cargo.HasCargoClass, Cargo.CC_PASSENGERS);
	cargos.KeepValue(1);
	return cargos.Begin();
}

function Cargo::GetMailId(){
	local cargos = AICargoList();
	cargos.Valuate(Cargo.HasCargoClass, Cargo.CC_MAIL);
	cargos.KeepValue(1);
	return cargos.Begin();
}