
class Tasks_Managers_Finance extends Task {
	function GetName(){
		return "Tasks_Finance";
	}
	
	function Run(){
		local money = Budget.GetAvailableMoney();
		Log.Info("Available money " + Finance.FormatMoney(money));

		money/=4;

		local budget_id = Company.GetInvestmentBudget();
		if(money > 0){
			Budget.AllocateAmount(budget_id, money);
			Log.Info("Added " + Finance.FormatMoney(money) + " to investment budget at " + Finance.FormatMoney(Budget.GetBudgetAmount(budget_id)));
		}else{
			Log.Info("Current investment budget at " + Finance.FormatMoney(Budget.GetBudgetAmount(budget_id)));
		}

		local budgets = Storage.ValueExists("budgets");
		foreach(budget_id, budget in Storage.GetValue("budgets")){
			local amount = budget.credit - budget.debit;
			local percent = budget.debit * 1000 / budget.credit / 10.0;
			Log.Info(" - " + budget_id + ": " + Finance.FormatMoney(amount) + " [" + percent + "%] (" + budget.name + ")");
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