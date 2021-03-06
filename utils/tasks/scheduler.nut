class Scheduler {
	active  = null;
	enqueue  = null;
	sleeping = null;
	waiting  = null;
    goneToSleep = null;
    goneWaiting = null;

    constructor(){
        active  = [];
        enqueue  = [];
        sleeping = [];
        waiting  = [];
        goneToSleep = false;
        goneWaiting = false;
    }
}

function Scheduler::IsEmpty(){
    return !(enqueue.len() || sleeping.len() || waiting.len())
}

function Scheduler::Run(){
	do {
		Execute();
	}while(enqueue.len() || sleeping.len() || waiting.len());
}

function Scheduler::Execute(){
    // Some tasks gone to sleep, lets sort them so the first one to wake up is at the end
    if(goneToSleep){
        sleeping.sort(Scheduler.CompareSleepers);
        goneToSleep = false;
    }
    if(goneWaiting){
        waiting.sort(Scheduler.CompareWaiters);
        goneWaiting = false;
    }

    // Are there any tasks waking up add them first
    while(sleeping.len() && !sleeping.top().IsSleepy()){
        local task = sleeping.pop();
        task.WakeUp();
        active.push(task);
    }

    // Are there any tasks waking up add them first
    while(waiting.len() && !waiting.top().IsWaiting()){
        local task = waiting.pop();
        task.WakeUp();
        active.push(task);
    }

    // Add any unfinished tasks to the pool
    active.extend(enqueue);
    enqueue.clear();

    // Are there any active tasks
    if(active.len()){
        while(active.len()){
            local task = active[0];
            active.remove(0);
            //Log.Info("Scheduler: " + task.GetName());

            try {
                local start	= Controller.GetTick();
                if(task.Execute())
                    // Seems the task is not finished and needs to run again
                    EnqueueTask(task);

                if(start < Controller.GetTick() && (Controller.GetTick() - start) > 10){
                    Log.Warning("Task " + task.GetName() + " used " + (Controller.GetTick() - start) + " ticks to run");
                }
            }catch(err){
                Log.Error("Task " + task.GetName() + " has thrown an error");
                Log.Error(err);
            }
        }
    }else if(sleeping.len()){
        // All tasks are asleep so lets sleep until one wakes up
        local ticks = max(1, sleeping.top().SleepAmount());
        Controller.Sleep(ticks);
    }else if(waiting.len()){
        // All tasks are waiting till a next day just close the eyes for a moment
        Controller.Sleep(10);
    }else{
        throw "This shouldn't happen... I've run out of tasks to execute bye bye beautiful world";
    }
}

function Scheduler::CompareSleepers(a, b){
	if(a.SleepAmount() == b.SleepAmount()) return 0;
	return a.SleepAmount() > b.SleepAmount() ? -1 : 1;
}

function Scheduler::CompareWaiters(a, b){
	if(a.WaitAmount() == b.WaitAmount()) return 0;
	return a.WaitAmount() > b.WaitAmount() ? -1 : 1;
}

function Scheduler::EnqueueTask(task){
    task._parent = this;
    if(task.IsSleepy()){
        // This task seems sleepy, lets put it to bed
        sleeping.push(task);
        goneToSleep = true;
    }else if(task.IsWaiting()){
        // This task seems to be waiting for time to pass-by
        waiting.push(task);
        goneWaiting = true;
    }else{
        // Give it an other go
        enqueue.push(task);
    }
    return this;
}