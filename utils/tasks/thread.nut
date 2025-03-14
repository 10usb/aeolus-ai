/*
 * A wrapper around a stack of tasks
 */
class Thread {
	stack = null;
    active = null;
    scheduler = null;

    constructor(scheduler, task){
        this.stack = [];
        this.scheduler = scheduler;
        this.active = task.SetThread(this);
    }

	function GetName(){
        return this.active.GetName();
    }

    function Execute(){
        if(this.active.Run())
            return true;
        
        if(this.stack.len() <= 0)
            return false;

        this.active = this.stack.pop();
        return true;
    }
    
    function Push(task){
        this.stack.push(this.active);
        this.active = task;
        return task;
    }
    
    function Remove(task){
        local index = 0;
        while(index < this.stack.len()){
            if(this.stack[index] == task)
                break;

            index++;
        }

        if(this.stack[index] != task)
            return;

        this.stack.remove(index);
    }

    function IsSleepy(){
        return this.active.IsSleepy();
    }

    function SleepAmount(){
        return this.active.SleepAmount();
    }

    function IsWaiting(){
        return this.active.IsWaiting();
    }

    function WaitAmount(){
        return this.active.WaitAmount();
    }

    function WakeUp(){
        return this.active.WakeUp();
    }
}