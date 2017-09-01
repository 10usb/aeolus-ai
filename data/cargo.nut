class Cargo {
	constructor(){
	}
}

function Cargo::GetWeight(cargo_id, amount){
	if(AICargo.GetCargoLabel(cargo_id)=="PASS") return amount / 20;
	if(AICargo.GetCargoLabel(cargo_id)=="MAIL") return amount / 4;
	if(AICargo.GetCargoLabel(cargo_id)=="GOOD") return amount / 2;
	if(AICargo.GetCargoLabel(cargo_id)=="VALU") return amount / 10;
	if(AICargo.GetCargoLabel(cargo_id)=="LVST") return amount / 5;
	return amount;
}