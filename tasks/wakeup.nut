class WakeUp extends Task {
	function GetName(){
		return "WakeUp";
	}
	
	function Run(){
		this.GetParent().EnqueueTask(RepayLoan());
		this.GetParent().EnqueueTask(Tasks_Finance());
        return false;
	}
}