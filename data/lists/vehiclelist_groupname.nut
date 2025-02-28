class VehicleList_GroupName extends AIList {
	constructor(name){
        ::AIList.constructor();

        foreach(group_id, vehicle_type in GroupList_Name(name))
            this.AddList(AIVehicleList_Group(group_id));
	}
}