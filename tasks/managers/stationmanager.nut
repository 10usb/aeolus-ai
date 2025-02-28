/**
* The task of the station manager is to analyze each station for profitability.
* This can result in:
* - adding more vehicles because more cargo is waiting to be transported
* - selling/repurposing vehicles that are in excess
* - giving vehicles more profitable routes, then they currently have
* - sell the station as it is deemed to be unprofitable
*
* For (new) vehicles to be added/redirected, a new road/rail path that currently
* doesn't exist might need to be added first. The manager can not do this, but
* it can suggest an investment opportunity to the investment manager.
*/
class Tasks_StationManager extends Task {
    static INIT      	= 0;
    
    state = 0;
    
    constructor(){
        state = Init();
    }

    function GetName(){
        return "Tasks_StationManager";
    }

    function Run(){
        switch(state){
            case INIT: return Init();
        }

        return false;
    }

    function Init(){

    }
}