require("includes.nut");

import("queue.fibonacci_heap", "FibonacciHeap", 2);

class Aeolus extends AIController {
}

function Aeolus::Start(){
	// Set company default
	Company.Init(); // TODO should be in a task

	local scheduler = Scheduler();

	// Add some initial tasks
	scheduler.EnqueueTask(RepayLoad());
	scheduler.EnqueueTask(BuildOpportunities());
	scheduler.EnqueueTask(FindOpportunities());
	scheduler.EnqueueTask(AirStationManager());
	scheduler.EnqueueTask(AircraftManager());

	// Main loop and should never end...
	scheduler.Run();
}

function Aeolus::Save(){
	return Storage.values;
}

function Aeolus::Load(version, data){
	if(version == 1){
		AILog.Info("Loading from version " + version);
		foreach(key, value in data) {
			Storage.values.rawset(key, value);
		}
		// TODO Start a find destination thread for each opportunity not yet buildable
	}
}