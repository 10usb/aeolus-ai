/*
 * A wrapper around a stack of tasks
 */
class Thread {
	stack = null;
    active = null;

    constructor(task){
        this.stack = [];
        this.active = task;
    }

	function GetName(){
        this.active.GetName();
    }

    function Execute(){
        if(this.active == null)
            return false;

        local task = this.tasks.top();
        
        if(this.active.Run())
            return true;
        
        if(this.tasks.len() <= 0){
            this.active = null;
            return false;
        }

        active = this.tasks.pop();
        return true;
    }
    
    function Push(task){
        this.tasks.push(task);
        return task;
    }

    function IsSleepy(){
        return this.active.IsSleepy();
    }

    function SleepAmount(){
        this.active.SleepAmount();
    }

    function IsWaiting(){
        this.active.IsWaiting();
    }

    function WaitAmount(){
        this.active.WaitAmount();
    }
}