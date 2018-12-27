class OpportunityList extends AIList {
	constructor(){
        ::AIList.constructor();
        if(Storage.ValueExists("opportunities")){
            foreach(opportunity_id, dummy in Storage.GetValue("opportunities")){
                AddItem(opportunity_id, 0);
            }
        }
	}
}