class Thread {
	_ticks = 0;
	_sleep = 0;
	function Run();
}

function Thread::Sleep(ticks){
	_ticks = Aeolus.GetTick();
	_sleep = ticks;
	return true;
}

function Thread::IsSleepy(){
	if(Aeolus.GetTick() < _ticks){
		return false;
	}
	if(Aeolus.GetTick() >= (_ticks + _sleep)){
		return false;
	}
	return true;
}

function Thread::WakeUp(){
	_ticks = 0;
	_sleep = 0;
}

function Thread::SleepAmount(){
	return (_ticks + _sleep) - Aeolus.GetTick();
}