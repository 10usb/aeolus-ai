class Budget {
	static accounting = { instance = null };
}

function Budget::GetCount(){
	if(Storage.ValueExists("budgets")) return Storage.GetValue("budgets").len();
	return 0;
}

function Budget::GetList(){
	local list = AIList();
	if(Storage.ValueExists("budgets")){
		foreach(budget_id, dummy in Storage.GetValue("budgets")){
			list.AddItem(budget_id, 0);
		}
	}
	return list;
}

function Budget::IsValidBudget(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) return 0;
	return 1;
}

function Budget::RemoveBudget(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	AILog.Info("Budget closed at " + budget.amount + " / " + budget.total + " (" + (budget.amount * 100 / budget.total) + "%)");

	budgets.rawdelete(budget_id);
}

function Budget::Create(amount, name){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});

	local id = Storage.ValueExists("budget.increment") ? Storage.GetValue("budget.increment") : Storage.SetValue("budget.increment", 1);
	Storage.SetValue("budget.increment", id + 1);

	budgets.rawset(id, {
		id = id,
		name = name,
		amount = amount.tointeger(),
		total = amount.tointeger(),
		created = AIDate.GetCurrentDate()
	});
	return id;
}

function Budget::GetAmount(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");
	return budgets.rawget(budget_id).amount;
}

function Budget::Add(budget_id, amount){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	budget.amount+= amount.tointeger();
	budget.total+= amount.tointeger();
}

/**
 * Takes the amount from the budget if we are not in a
 * virtual dept.
 */
function Budget::Take(budget_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	if(amount > budget.amount) return false;

	local available = Finance.GetAvailableMoney() + budget.amount;
	if(available < amount) return false;

	budget.amount-= amount;
	return Finance.GetMoney(amount);
}

/**
 * Adds money to the budget is available
 */
function Budget::Request(budget_id, request){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	local needed = amount - budget.amount;

	local available = Finance.GetAvailableMoney();
	if(available < 1) return;

	if(available < needed)
		needed = available;

	budget.amount+= needed;
}

/**
 * Return the remaining amount of money after an estimated cost was taken
 */
function Budget::Return(budget_id, amount){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	budget.amount+= amount.tointeger();
}

/**
 * To tranfer money from one budget to an other
 */
function Budget::Transfer(source_id, destination_id, amount){
	// normalize input
	amount = amount.tointeger();

	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(source_id)) throw("Budget source not exists");
	if(!budgets.rawin(destination_id)) throw("Budget destination not exists");

	local source = budgets.rawget(source_id);
	local destination = budgets.rawget(destination_id);

	// Make sure the soure has enough
	if(amount > source.amount) return false;

	source.amount-= amount;
	destination.amount+= amount;
	destination.total+= amount;
	return true;
}

/**
 @deprecated
 */
function Budget::Start(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	if(Budget.accounting.instance != null){
		throw("Can't start tracking costs when not stopped");
	}
	Budget.accounting.instance = AIAccounting();
}

/**
 @deprecated
 */
function Budget::Stop(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	if(Budget.accounting.instance != null){
		budget.used-= Budget.accounting.instance.GetCosts();
		Budget.accounting.instance = null;
	}
	//AILog.Info("Budget " + budget.used + " / " + budget.amount + " (" + (budget.used * 100 / budget.amount) + "%)");
}