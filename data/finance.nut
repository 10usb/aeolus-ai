class Finance {
}

function Finance::GetMonthlyExpenses(){
	return Math.max(
		abs(Company.GetQuarterlyExpenses(Company.COMPANY_SELF, Company.CURRENT_QUARTER + 1)),
		abs(Company.GetQuarterlyExpenses(Company.COMPANY_SELF, Company.CURRENT_QUARTER))
	) / 3;
}

function Finance::GetMonthlyIncome(){
	return Math.max(
		abs(Company.GetQuarterlyIncome(Company.COMPANY_SELF, Company.CURRENT_QUARTER + 1)),
		abs(Company.GetQuarterlyIncome(Company.COMPANY_SELF, Company.CURRENT_QUARTER))
	) / 3;
}

function Finance::GetMonthlyProfit(){
	return (
		Math.max(
			abs(Company.GetQuarterlyIncome(Company.COMPANY_SELF, Company.CURRENT_QUARTER + 1)),
			abs(Company.GetQuarterlyIncome(Company.COMPANY_SELF, Company.CURRENT_QUARTER))
		) + Math.max(
			abs(Company.GetQuarterlyExpenses(Company.COMPANY_SELF, Company.CURRENT_QUARTER + 1)),
			abs(Company.GetQuarterlyExpenses(Company.COMPANY_SELF, Company.CURRENT_QUARTER)))
	) / 3;
}

function Finance::GetAvailableMoney(){
	local available = AICompany.GetMaxLoanAmount() - AICompany.GetLoanAmount();
	available+= AICompany.GetBankBalance(AICompany.COMPANY_SELF);
	available-= (Finance.GetMonthlyExpenses() * 1.5).tointeger();

	local budgets = Budget.GetList();
	budgets.Valuate(Budget.GetRemain);
	available-= List.GetSum(budgets);
	return available;
}

function Finance::GetMoney(amount){
	if(amount < AICompany.GetBankBalance(AICompany.COMPANY_SELF)) return true;

	local additional = (ceil(amount / 10000.0).tointeger() - floor(AICompany.GetBankBalance(AICompany.COMPANY_SELF) / 10000.0).tointeger()) * 10000;
	local neededloan = AICompany.GetLoanAmount() + additional;

	if(neededloan <= AICompany.GetMaxLoanAmount()){
		AICompany.SetMinimumLoanAmount(neededloan.tointeger());
		return true;
	}
	return false;
}

function Finance::Repay(){
	if(AICompany.GetLoanAmount() <=0) return true
	if(AICompany.GetBankBalance(AICompany.COMPANY_SELF) < Finance.GetMonthlyExpenses()) return false;

	local amount = floor((AICompany.GetBankBalance(AICompany.COMPANY_SELF) - Finance.GetMonthlyExpenses()) / 10000.0).tointeger() * 10000;
	if(amount <= 0)  return false;

	AICompany.SetMinimumLoanAmount(Math.max(0, AICompany.GetLoanAmount() - amount));
	return true;
}