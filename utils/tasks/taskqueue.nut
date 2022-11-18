class TaskQueue extends Task {
	tasks = null;

    constructor(){
        tasks  = [];
    }
}

function TaskQueue::GetName(){
    return "TaskQueue";
}

function TaskQueue::RunEmpty(){
    return false;
}

function TaskQueue::Run(){
    if(tasks.len() <= 0) return this.RunEmpty();
    
    if(!tasks[0].Run()){
        tasks.remove(0);
    }

    return true;
}

function TaskQueue::IsSleepy(){
    if(::Task.IsSleepy()) return true;
    if(tasks.len()) return tasks[0].IsSleepy();
    return false;
}

function TaskQueue::SleepAmount(){
    if(::Task.IsSleepy()) return ::Task.SleepAmount();
    if(tasks.len()) return tasks[0].SleepAmount();
    return 0;
}

function TaskQueue::IsWaiting(){
    if(::Task.IsWaiting()) return true;
    if(tasks.len()) return tasks[0].IsWaiting();
    return false;
}

function TaskQueue::WaitAmount(){
    if(::Task.IsWaiting()) return ::Task.WaitAmount();
    if(tasks.len()) return tasks[0].WaitAmount();
    return 0;
}

function TaskQueue::WakeUp(){
    if(!::Task.WakeUp() && tasks.len()){
        tasks[0].WakeUp();
    }
}

function TaskQueue::EnqueueTask(task){
    task._parent = this;
    tasks.push(task);
    return task;
}