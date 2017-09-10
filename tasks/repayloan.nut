
class RepayLoad extends Thread {
}

function RepayLoad::Run(){
	Finance.Repay();
	return this.Wait(10);
}