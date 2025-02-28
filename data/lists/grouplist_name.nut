class GroupList_Name extends AIList {
	constructor(name){
        ::AIList.constructor();

        name = "[" + Company.ResolveCompanyID(Company.COMPANY_SELF) + "] " + name;

        local groups = AIGroupList(GroupList_Name.IsName, name);
        groups.Valuate(AIGroup.GetVehicleType);
        groups = Lists.Flip(groups);

        foreach(vehicle_type in Vehicle.GetTypes()){
            if(groups.HasItem(vehicle_type))
                continue;
            
            local group_id = AIGroup.CreateGroup(vehicle_type, AIGroup.GROUP_INVALID);
            AIGroup.SetName(group_id, name);
            groups.AddItem(vehicle_type, group_id);
            Log.Info("Created group '" + name + "' for type #" + vehicle_type);
        }

        foreach(vehicle_type, group_id in groups)
            this.AddItem(group_id, vehicle_type);
	}
}

function GroupList_Name::IsName(group_id, name){
    return AIGroup.GetName(group_id) == name;
}