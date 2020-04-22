
class RepayLoan extends Task {
	function GetName(){
		return "RepayLoan";
	}
	
	function Run(){
		Finance.Repay();
		return this.Wait(10);
	}
}