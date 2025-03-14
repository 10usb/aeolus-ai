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

    function IsEmpty(){
        return !(enqueue.len() || sleeping.len() || waiting.len())
    }

    function Run(){
        do {
            Execute();
        }while(enqueue.len() || sleeping.len() || waiting.len());
    }

    function Execute(){
        // Some threads gone to sleep, lets sort them so the first one to wake up is at the end
        if(goneToSleep){
            sleeping.sort(Scheduler.CompareSleepers);
            goneToSleep = false;
        }
        if(goneWaiting){
            waiting.sort(Scheduler.CompareWaiters);
            goneWaiting = false;
        }

        // Are there any threads waking up add them first
        while(sleeping.len() && !sleeping.top().IsSleepy()){
            local thread = sleeping.pop();
            thread.WakeUp();
            active.push(thread);
        }

        // Are there any threads waking up add them first
        while(waiting.len() && !waiting.top().IsWaiting()){
            local thread = waiting.pop();
            thread.WakeUp();
            active.push(thread);
        }

        // Add any unfinished threads to the pool
        active.extend(enqueue);
        enqueue.clear();

        // Are there any active threads
        if(active.len()){
            while(active.len()){
                local thread = active[0];
                active.remove(0);
                //Log.Info("Scheduler: " + thread.GetName());

                //try {
                    local start	= Controller.GetTick();
                    if(thread.Execute())
                        // Seems the thread is not finished and needs to run again
                        this.Enqueue(thread);

                    if(start < Controller.GetTick() && (Controller.GetTick() - start) > 10){
                        Log.Warning("Task " + thread.GetName() + " used " + (Controller.GetTick() - start) + " ticks to run");
                    }
                // }catch(err){
                //     Log.Error("Task " + thread.GetName() + " has thrown an error");
                //     Log.Error(err);
                // }
            }
        }else if(sleeping.len()){
            // All threads are asleep so lets sleep until one wakes up
            local ticks = max(1, sleeping.top().SleepAmount());
            Controller.Sleep(ticks);
        }else if(waiting.len()){
            // All threads are waiting till a next day just close the eyes for a moment
            Controller.Sleep(10);
        }else{
            throw "This shouldn't happen... I've run out of tasks to execute bye bye beautiful world";
        }
    }

    static function CompareSleepers(a, b){
        if(a.SleepAmount() == b.SleepAmount()) return 0;
        return a.SleepAmount() > b.SleepAmount() ? -1 : 1;
    }

    static function CompareWaiters(a, b){
        if(a.WaitAmount() == b.WaitAmount()) return 0;
        return a.WaitAmount() > b.WaitAmount() ? -1 : 1;
    }

    function Enqueue(thread){
        if(thread.IsSleepy()){
            // This thread seems sleepy, lets put it to bed
            sleeping.push(thread);
            goneToSleep = true;
        }else if(thread.IsWaiting()){
            // This thread seems to be waiting for time to pass-by
            waiting.push(thread);
            goneWaiting = true;
        }else{
            // Give it an other go
            enqueue.push(thread);
        }
        return this;
    }

    function EnqueueTask(task){
        return this.Enqueue(Thread(this, task));
    }
}