
class Tasks_Finance extends Task {
	function GetName(){
		return "Tasks_Finance";
	}
	
	function Run(){
		local money = Finance.GetAvailableMoney();
		Log.Info("Available money " + money);

		money/=4;

		local budget_id = Company.GetInvestmentBudget();
		if(money > 0){
			Budget.Add(budget_id, money);
			Log.Info("Added " + money + " to investment budget at " + Budget.GetAmount(budget_id));
		}else{
			Log.Info("Current investment budget at " + Budget.GetAmount(budget_id));
		}

		local budgets = Storage.ValueExists("budgets");
		foreach(budget_id, budget in Storage.GetValue("budgets")){
			Log.Info(" - " + budget_id + ": " + budget.amount + " (" + budget.name + ")");
		}


		local now = AIDate.GetCurrentDate();
		local year = AIDate.GetYear(now);
		local month = AIDate.GetMonth(now) + 1;
		if(month == 13){
			month = 1;
			year++;
		}
		Log.Info("Next check " + year + "-" + month + "-1");
		local nextMonth = AIDate.GetDate(year, month, 1);
		return this.WaitUntil(nextMonth);
	}
}