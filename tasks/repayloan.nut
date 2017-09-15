
class RepayLoad extends Thread {
}

function RepayLoad::GetName(){
	return "RepayLoad";
}

function RepayLoad::Run(){
	Finance.Repay();
	return this.Wait(10);
}