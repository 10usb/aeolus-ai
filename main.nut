require("includes.nut");

import("queue.fibonacci_heap", "FibonacciHeap", 2);

class Aeolus extends AIController {
	static threads = [];
	static enqueue	= [];
	static sleeping	= [];
}

function Aeolus::Start(){
	AILog.Info("Aeolus Started");

	// Set company default
	Company.Init();

	// Add some initial threads
	Aeolus.threads.push(FindOpportunities());

	// Main loop and should never end...
	do {
		// Are there any threads waking up add them first
		while(Aeolus.sleeping.len() && !Aeolus.sleeping.top().IsSleepy()){
			Aeolus.threads.push(Aeolus.sleeping.pop());
		}

		// Add any unfinished threads to the pool
		Aeolus.threads.extend(Aeolus.enqueue);
		Aeolus.enqueue.clear();

		// Are there any active threads
		if(Aeolus.threads.len()){
			local goneToSleep = false;

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
					}else{
						// Give it an other go
						Aeolus.enqueue.push(thread);
					}
				}

				if(start < Aeolus.GetTick() && (Aeolus.GetTick() - start) > 10){
					AILog.Warning("Thread used " + (Aeolus.GetTick() - start) + " ticks to run");
				}
			}

			// Some threads gone to sleep, lets sort them so the first one to wake up is at the end
			if(goneToSleep) Aeolus.sleeping.sort(Aeolus.CompareThreads);

		}else if(Aeolus.sleeping.len()){
			// All threads are asleep so lets sleep until one wakes up
			local ticks = max(1, Aeolus.sleeping.top().SleepAmount());
			AILog.Info("Sleeping for " + ticks + " ticks");
			Aeolus.Sleep(ticks);
		}else{
			throw("This should never happen...");
		}
	}while(Aeolus.enqueue.len() || Aeolus.sleeping.len());

	throw("There are no threads....");
}

function Aeolus::CompareThreads(a, b){
	if(a.SleepAmount() == b.SleepAmount()) return 0;
	return a.SleepAmount() > b.SleepAmount() ? -1 : 1;
}

function Aeolus::AddThread(thread){
    Aeolus.enqueue.push(thread);
}

function Aeolus::Save(){ return {}; }
function Aeolus::Load(version, data){}