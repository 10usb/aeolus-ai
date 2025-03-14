class WakeUp extends Task {
	function GetName(){
		return "WakeUp";
	}
	
	function Run(){
		this.EnqueueTask(RepayLoan());
		this.EnqueueTask(Tasks_Managers_Finance());
		this.EnqueueTask(Tasks_VehicleManager());
        return false;
	}
}