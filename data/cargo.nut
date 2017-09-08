class Cargo extends AICargo {
	constructor(){
	}
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