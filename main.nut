require("includes.nut");

class Controller extends AIController {
	scheduler = null;
	loaded = false;

	constructor(){
		scheduler = Scheduler();
	}
}

function Controller::Start(){
	Company.SetAutoRenewStatus(false);

	// Add initial task
	if(!loaded){
		scheduler.EnqueueTask(CreatePersonality());
	}else{
		scheduler.EnqueueTask(WakeUp());
	}

	scheduler.EnqueueTask(Debugging());

	// Main loop and it should never end...
	scheduler.Run();
}

function Controller::Save(){
	return Storage.values;
}

function Controller::Load(version, data){
	if(version == 1){
		loaded = true;
		foreach(key, value in data){
			Storage.values.rawset(key, value);
		}
	}
}