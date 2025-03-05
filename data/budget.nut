class Budget {
	static stats = { total = 0 };
}

/**
 Get the amount of money available not allocated to any budget
 */
function Budget::GetAvailableMoney(){
	return Finance.GetAvailableMoney() - Budget.stats.total;
}

/**
 To check if a budget id is valid
 */
function Budget::IsValidBudget(budget_id){
	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) return 0;
	return 1;
}
/**
 Get the name of the budget
 */
function Budget::GetName(budget_id){
	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	local budget = budgets.rawget(budget_id);
	return budget.name;
}

/**
 Get the amount of money in the budget
 */
function Budget::GetBudgetAmount(budget_id){
	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	local budget = budgets.rawget(budget_id);
	return budget.credit - budget.debit;
}

/**
 To create a new budget
 */
function Budget::CreateBudget(name){
	local budgets = Storage.GetOrCreateValue("budgets", {});

	local id = Storage.ValueExists("budget.increment") ? Storage.GetValue("budget.increment") : Storage.SetValue("budget.increment", 1);
	Storage.SetValue("budget.increment", id + 1);

	budgets.rawset(id, {
		id = id,
		name = name,
		credit = 0,
		debit = 0,
		created = AIDate.GetCurrentDate()
	});
	return id;
}

/**
 Delete the budget and return the amount
 */
function Budget::DeleteBudget(budget_id){
	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id))
		return false;

	local budget = budgets.rawget(budget_id);
	Budget.stats.total-= budget.credit - budget.debit;

	budgets.rawdelete(budget_id);
	return true;
}

/**
 Allocate an amount of money to a budget, this can not exceed 
 the amount freely available
 */
function Budget::AllocateAmount(budget_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	if(amount > Budget.GetAvailableMoney())
		return false;

	local budget = budgets.rawget(budget_id);
	budget.credit+= amount;
	Budget.stats.total+= amount;

	// Normalize the values
	budget.credit-= budget.debit;
	budget.debit = 0;
	return true;
}

/**
 Withdraw an amount from the budget and make it available for spending
 */
function Budget::Withdraw(budget_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	local budget = budgets.rawget(budget_id);
	if(amount > (budget.credit - budget.debit))
		return false;

	local available = Finance.GetAvailableMoney();
	if(available < amount)
		return false;

	budget.debit+= amount;
	Budget.stats.total-= amount;
	return Finance.GetMoney(amount);
}

/**
 Refund available money back into the budget, should be used
 when not all of the withdrawn money is used.
 */
 function Budget::Refund(budget_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	if(amount > AICompany.GetBankBalance(AICompany.COMPANY_SELF))
		return false;

	local budget = budgets.rawget(budget_id);
	budget.debit-= amount;
	Budget.stats.total+= amount;
	return true;
}

/**
 * To tranfer money from one budget to an other
 */
function Budget::Transfer(source_id, destination_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(source_id)) throw("Budget source does not exist");
	if(!budgets.rawin(destination_id)) throw("Budget destination does not exist");

	local source = budgets.rawget(source_id);
	local destination = budgets.rawget(destination_id);

	// Make sure the soure has enough
	if(amount > source.amount) return false;

	source.debit+= amount;
	destination.credit+= amount;
	return true;
}

/**
 * Adds only the needed amount to the budget if available
 * @deprecated
 */
function Budget::Request(budget_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.GetOrCreateValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget does not exist");

	local budget = budgets.rawget(budget_id);
	local needed = amount - (budget.credit - budget.debit);

	if(needed < Budget.GetAvailableMoney())
		return false;

	budget.credit+= needed;
	Budget.stats.total+= needed;
	return true;
}

/**
 * Takes the amount from the budget if we are not in a virtual dept.
 */
function Budget::Take(budget_id, amount){
	return Budget.Withdraw(budget_id, amount);
}