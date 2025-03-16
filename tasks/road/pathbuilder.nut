/**
 * This task is mainly used as debugging. It's able to build (not yet fully
 * functional) from an array of tiles, the raw format what is obtained from an
 * A-star path finding. In the future it might also be used to build temperal
 * paths for trains to go over, while existing track segments get upgraded to
 * be more effectient.
 */
class Tasks_RoadPathBuilder extends Task {
    path = null;
    offset = 0;
    signs = null;
    budget_id = 0;
    roadType = null;
    error = 0;

	constructor(budget_id, roadType){
        this.budget_id = budget_id;
        this.roadType = roadType;
        this.path = [];
        this.offset = 1;
        this.signs = Signs();

        Log.Info("Good morning Benny here we go!")
        Log.Info("We're building a road and it's time to roll.");
        //Log.Info("Push the dirt, move the rocks.");
        //Log.Info("Clear the way with your big bulldozer block.");
	}

    function GetName(){
        return "Tasks_RoadPathBuilder"
    }

    function Append(path){
        this.path.extend(path);
    }

    function Finalize(){
        // Nothing to do here as this rail-processor doesn't hold anything back
    }

    function Run(){
        local cost = Road.GetBuildCost(this.roadType, Road.BT_ROAD) * 24;
        
        local cursor = this.offset;
        for(local count = 0; count < 10 && cursor + 1 < this.path.len(); count++, cursor++){
            local tile = this.path[cursor];

            if(Tile.IsFarmTile(tile)){
                cost += Tile.GetBuildCost(Tile.BT_CLEAR_FIELDS);
            }else if(Tile.IsRoughTile(tile)){
                cost += Tile.GetBuildCost(Tile.BT_CLEAR_ROUGH);
            }else if(Tile.IsSlopeRamp(Tile.GetSlope(tile))){
                cost += Tile.GetBuildCost(Tile.BT_FOUNDATION);
            }
        }

        if(Budget.GetBudgetAmount(this.budget_id) < cost){
            Log.Warning("Budget '" + Budget.GetName(this.budget_id) + "' not sufficient, need " + Finance.FormatMoney(cost) + " available "+ Finance.FormatMoney(Budget.GetBudgetAmount(this.budget_id)));
            return this.Wait(30);
        }else if(!Budget.Withdraw(this.budget_id, cost)){
            Log.Warning("Failed to withdraw money for road, need " + Finance.FormatMoney(cost) + " available "+ Finance.FormatMoney(Budget.GetBudgetAmount(this.budget_id)));
            return this.Wait(3);
        }

        Road.SetCurrentRoadType(this.roadType);
        for(local count = 0; count < 10 && this.offset < this.path.len(); count++){
            local from = this.path[this.offset - 1];
            local index = this.path[this.offset];

            if(this.offset + 1 < this.path.len()){
                local to = this.path[this.offset + 1];

                local distance = Tile.GetDistanceManhattanToTile(index, to);

                if(distance > 1 && !AIBridge.IsBridgeTile(index)){
                    local bridges = AIBridgeList_Length(distance + 1);
                    foreach(bridge_id, _ in bridges){
                        cost = AIBridge.GetPrice(bridge_id, distance) * 1.2;

                        if(Budget.GetBudgetAmount(this.budget_id) < cost){
                            Log.Warning("Budget '" + Budget.GetName(this.budget_id) + "' not sufficient, need " + Finance.FormatMoney(cost) + " available "+ Finance.FormatMoney(Budget.GetBudgetAmount(this.budget_id)));
                            return this.Wait(30);
                        }else if(!Budget.Withdraw(this.budget_id, cost)){
                            Log.Warning("Failed to withdraw money for bridge, need " + Finance.FormatMoney(cost) + " available "+ Finance.FormatMoney(Budget.GetBudgetAmount(this.budget_id)));
                            return this.Wait(3);
                        }

                        Log.Info(AIBridge.GetName(bridge_id, Vehicle.VT_ROAD) + ": " + AIBridge.GetMinLength(bridge_id) + "-" + AIBridge.GetMaxLength(bridge_id));
                        if(AIBridge.BuildBridge(Vehicle.VT_ROAD, bridge_id, index, to))
                            break;
                    }
                }
            }

            if(Road.AreRoadTilesConnected(from, index)){
                this.offset++;
                continue;
            }


            if(!Road.BuildRoad(from, index)){
                cost = Road.GetBuildCost(this.roadType, Road.BT_ROAD) * 2;

                if(Tile.IsFarmTile(from) || Tile.IsFarmTile(from))
                    cost+= Tile.GetBuildCost(Tile.BT_CLEAR_FIELDS) * 2;

                if(AICompany.GetBankBalance(AICompany.COMPANY_SELF) < cost)
                    return true;
            }

            // Retry up to 5 times
            if(this.error < 5 && !Road.AreRoadTilesConnected(from, index)){
                this.error++;
                continue;
            }

            this.error = 0;
            this.offset++;
        }

        //Log.Info("PathBuilder: " + this.offset + " < " + this.path.len());
        if(this.offset < this.path.len())
            return this.error > 0 ? this.Sleep(100) : true;

        this.signs.Clean();
        return false;
    }
}