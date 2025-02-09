class Cargo extends AICargo {
}

// function Cargo::GetWeight(cargo_id, amount){
// 	if(Cargo.GetCargoLabel(cargo_id) == "PASS") return amount / 20;
// 	if(Cargo.GetCargoLabel(cargo_id) == "MAIL") return amount / 4;
// 	if(Cargo.GetCargoLabel(cargo_id) == "GOOD") return amount / 2;
// 	if(Cargo.GetCargoLabel(cargo_id) == "VALU") return amount / 10;
// 	if(Cargo.GetCargoLabel(cargo_id) == "LVST") return amount / 5;
// 	return amount;
// }

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