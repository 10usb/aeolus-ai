
class Tasks_Managers_Finance extends Task {
	function GetName(){
		return "Tasks_Finance";
	}
	
	function Run(){
		local money = Budget.GetAvailableMoney();
		Log.Info("Available money " + Finance.FormatMoney(money));
		Log.Info("Money in Budget " + Finance.FormatMoney(Budget.stats.total));

		if(money < 0){
			local investment_budget_id = Company.GetInvestmentBudget();
			local needed = -money;
			if(needed > Budget.GetBudgetAmount(investment_budget_id))
				needed = Budget.GetBudgetAmount(investment_budget_id);
			
			if(needed > Finance.GetAvailableMoney())
				needed = Finance.GetAvailableMoney();
			
			Budget.RemoveAmount(investment_budget_id, needed);
			Log.Info("Withdrawn " + Finance.FormatMoney(needed) + " from investment budget, now at " + Finance.FormatMoney(Budget.GetBudgetAmount(investment_budget_id)));
		}

		if(money > 0)
			this.DistributeMoney(money);

		local budgets = Storage.ValueExists("budgets");
		foreach(budget_id, budget in Storage.GetValue("budgets")){
			local amount = budget.credit - budget.debit;
			local percent = budget.credit > 0 ? budget.debit * 1000 / budget.credit / 10.0 : -1;
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

	function DistributeMoney(money){
		// Setting aside money to replace vehicle is more important then
		// building new investments
		local savings = Storage.GetOrCreateValue("global.vehicle_replacement_savings", 0);
		local replacement_budget_id = Company.GetReplacementBudget();
		if(Budget.GetBudgetAmount(replacement_budget_id) < savings){
			local addition = savings - Budget.GetBudgetAmount(replacement_budget_id);
			if(addition > money)
				addition = money;

			Budget.AllocateAmount(replacement_budget_id, addition);
			Log.Info("Added " + Finance.FormatMoney(addition) + " to vehicle replacement budget at " + Finance.FormatMoney(Budget.GetBudgetAmount(replacement_budget_id)));

			money-= addition;

			if(money < 0)
				return;
		}


		// Any free money can be set aside to investe in new projects
		local investment_budget_id = Company.GetInvestmentBudget();
		local available = (Finance.GetAvailableMoney() * 0.9).tointeger();
		available-= Budget.stats.total;
		
		if(available > 0){
			Budget.AllocateAmount(investment_budget_id, available);
			Log.Info("Added " + Finance.FormatMoney(available) + " to investment budget at " + Finance.FormatMoney(Budget.GetBudgetAmount(investment_budget_id)));
		}
	}
}