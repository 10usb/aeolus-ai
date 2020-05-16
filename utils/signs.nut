class Signs {
	signs = null;

	constructor(){
		signs = [];
	}

	function Build(tile, text){
		signs.push(AISign.BuildSign(tile, text));
	}
	
	function Clean(){
		foreach(sign in signs){
			AISign.RemoveSign(sign);
		}
	}
}