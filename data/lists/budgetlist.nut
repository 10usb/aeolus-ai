class BudgetList extends AIList {
	constructor(){
        ::AIList.constructor();

        if(Storage.ValueExists("budgets")){
            foreach(budget_id, dummy in Storage.GetValue("budgets")){
                AddItem(budget_id, 0);
            }
        }
	}
}