class TaskQueue {
    name = null
	tasks = null;

    constructor(name){
        this.name = name;
        tasks  = [];
    }
}

function TaskQueue::GetName(){
	return name;
}

function TaskQueue::Run(){
}


function TaskQueue::IsSleepy(){

}

function TaskQueue::SleepAmount(){

}

function TaskQueue::IsWaiting(){

}

function TaskQueue::WaitAmount(){

}

function TaskQueue::WakeUp(){

}

function TaskQueue::EnqueueTask(task){
    tasks.push(task);
}