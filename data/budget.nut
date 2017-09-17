class Budget {

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
	AILog.Info("Budget closed at " + budget.used + " / " + budget.amount + " (" + (budget.used * 100 / budget.amount) + "%)");


	budgets.rawdelete(budget_id);
}

function Budget::Create(amount){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});

	local id = Storage.ValueExists("budget.increment") ? Storage.GetValue("budget.increment") : Storage.SetValue("budget.increment", 0);
	Storage.SetValue("budget.increment", id + 1);

	budgets.rawset(id, {
		id = id,
		amount = amount.tointeger(),
		used = 0,
		accounting = null,
		created = AIDate.GetCurrentDate()
	});
	return id;
}

function Budget::Start(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	if(budget.accounting!=null){
		throw("Can't start tracking costs when not stopped");
	}
	budget.accounting = AIAccounting();
}

function Budget::Stop(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	if(budget.accounting != null){
		budget.used+= budget.accounting.GetCosts();
		budget.accounting = null;
	}
	//AILog.Info("Budget " + budget.used + " / " + budget.amount + " (" + (budget.used * 100 / budget.amount) + "%)");
}

function Budget::GetAmount(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");
	return budgets.rawget(budget_id).amount;
}

function Budget::GetUsed(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");
	return budgets.rawget(budget_id).used;
}

function Budget::GetRemain(budget_id){
	local budgets = Storage.ValueExists("budgets") ? Storage.GetValue("budgets") : Storage.SetValue("budgets", {});
	if(!budgets.rawin(budget_id)) throw("Budget not exists");

	local budget = budgets.rawget(budget_id);
	return budget.amount - budget.used;
}