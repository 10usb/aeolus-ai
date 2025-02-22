class Signs {
	list = null;

	constructor(){
		list = AIList();
	}

	function Build(tile, text){
		if(list.HasItem(tile)){
			local sign_id = list.GetValue(tile);
			AISign.SetName(sign_id, "" + text)
			
		}else{
			local sign_id = AISign.BuildSign(tile, "" + text)
			list.AddItem(tile, sign_id);
		}
	}

	function Remove(tile){
		if(list.HasItem(tile)){
			AISign.RemoveSign(list.GetValue(tile));
			list.RemoveItem(tile);
		}
	}
	
	function Clean(){
		foreach(tile, sign_id in list){
			AISign.RemoveSign(sign_id);
		}
		list = AIList();
	}
}