class Signs {
	signs = [];
}

function Signs::Build(tile, text){
	signs.push(AISign.BuildSign(tile, text));
}

function Signs::Clean(){
	foreach(sign in signs){
		AISign.RemoveSign(sign);
	}
}

function Signs::GetNewLocations(count){
	local locations	= null;
	local exclusion	= AISignList();
	local signs		= null;
	do {
		AIController.Sleep(10);
		locations	= [];
		signs		= AISignList();
		signs.RemoveList(exclusion);

		local clear = false;
		foreach(sign_id, dummy in signs){
			if(AISign.GetName(sign_id)=="clear"){
				clear = true;
				break;
			}
			locations.push(AISign.GetLocation(sign_id));
		}
		if(clear){
			foreach(sign_id, dummy in AISignList()){
				AISign.RemoveSign(sign_id);
			}
			locations	= [];
			exclusion	= AISignList();
		}
	}while(locations.len() < count);
	locations.reverse();

	foreach(sign_id, dummy in signs) AISign.RemoveSign(sign_id);

	return locations;
}