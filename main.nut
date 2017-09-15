require("includes.nut");

import("queue.fibonacci_heap", "FibonacciHeap", 2);

class Aeolus extends AIController {
	static threads	= [];
	static enqueue	= [];
	static sleeping	= [];
	static waiting	= [];
}

function Aeolus::Start(){
	AILog.Info("Aeolus Started");

	// Set company default
	Company.Init(); // TODO should be in a task

	// Add some initial threads
	Aeolus.threads.push(RepayLoad());
	Aeolus.threads.push(BuildOpportunities());
	Aeolus.threads.push(FindOpportunities());
	Aeolus.threads.push(AirStationManager());
	Aeolus.threads.push(AirAircraftManager());

	// Main loop and should never end...
	do {
		// Are there any threads waking up add them first
		while(Aeolus.sleeping.len() && !Aeolus.sleeping.top().IsSleepy()){
			local thread = Aeolus.sleeping.pop();
			thread.WakeUp();
			Aeolus.threads.push(thread);
		}

		// Are there any threads waking up add them first
		while(Aeolus.waiting.len() && !Aeolus.waiting.top().IsWaiting()){
			local thread = Aeolus.waiting.pop();
			thread.WakeUp();
			Aeolus.threads.push(thread);
		}

		// Add any unfinished threads to the pool
		Aeolus.threads.extend(Aeolus.enqueue);
		Aeolus.enqueue.clear();

		// Are there any active threads
		if(Aeolus.threads.len()){
			local goneToSleep = false;
			local goneWaiting = false;

			while(Aeolus.threads.len()){
				local thread = Aeolus.threads[0];
				Aeolus.threads.remove(0);

				local start	= Aeolus.GetTick();
				if(thread.Run()){
					// Seems the thread is not finished and needs to run again
					if(thread.IsSleepy()){
						// This thread seems sleepy, lets put it to bed
						Aeolus.sleeping.push(thread);
						goneToSleep = true;
					}else if(thread.IsWaiting()){
						// This thread seems to be waiting for time to pass-by
						Aeolus.waiting.push(thread);
						goneWaiting = true;
					}else{
						// Give it an other go
						Aeolus.enqueue.push(thread);
					}
				}

				if(start < Aeolus.GetTick() && (Aeolus.GetTick() - start) > 10){
					AILog.Warning("Thread " + thread.GetName() + " used " + (Aeolus.GetTick() - start) + " ticks to run");
				}
			}

			// Some threads gone to sleep, lets sort them so the first one to wake up is at the end
			if(goneToSleep) Aeolus.sleeping.sort(Aeolus.CompareSleepers);
			if(goneToSleep) Aeolus.waiting.sort(Aeolus.CompareWaiters);

		}else if(Aeolus.sleeping.len()){
			// All threads are asleep so lets sleep until one wakes up
			local ticks = max(1, Aeolus.sleeping.top().SleepAmount());
			//AILog.Info("Sleeping for " + ticks + " ticks");
			Aeolus.Sleep(ticks);
		}else{
			throw("This should never happen...");
		}
	}while(Aeolus.enqueue.len() || Aeolus.sleeping.len() || Aeolus.waiting.len());

	throw("There are no threads....");
}

function Aeolus::CompareSleepers(a, b){
	if(a.SleepAmount() == b.SleepAmount()) return 0;
	return a.SleepAmount() > b.SleepAmount() ? -1 : 1;
}

function Aeolus::CompareWaiters(a, b){
	if(a.WaitAmount() == b.WaitAmount()) return 0;
	return a.WaitAmount() > b.WaitAmount() ? -1 : 1;
}

function Aeolus::AddThread(thread){
    Aeolus.enqueue.push(thread);
}

function Aeolus::Save(){ return {}; }
function Aeolus::Load(version, data){}