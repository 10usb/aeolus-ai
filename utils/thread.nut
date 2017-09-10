class Thread {
	_ticks = 0;
	_sleep = 0;
	_date  = null;
	function Run();
}

function Thread::Sleep(ticks){
	_ticks = Aeolus.GetTick();
	_sleep = ticks;
	return true;
}

function Thread::SleepDays(days){
	_date  = {};
	while(days > 0){
		_date.rawset(AIDate.GetCurrentDate() + days, true);
		days--;
	}
	return true;
}

function Thread::IsSleepy(){
	if(_date != null) return _date.rawin(AIDate.GetCurrentDate());

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
	_date  = null;
}

function Thread::SleepAmount(){
	if(_date != null) return 50;
	return (_ticks + _sleep) - Aeolus.GetTick();
}