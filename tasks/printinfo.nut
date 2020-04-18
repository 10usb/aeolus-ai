
class PrintInfo extends Task {
	message = null;

	constructor(message){
		this.message = message;
	}
	
	function GetName(){
		return "PrintInfo";
	}
	
	function Run(){
		Log.Info(message);
		return false;
	}
}
