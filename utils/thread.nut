class Thread {
	_ticks = 0;
	_sleep = 0;
	_date  = null;
	function Run();
	function GetName();
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

function Thread::SleepAmount(){
	return (_ticks + _sleep) - Aeolus.GetTick();
}

function Thread::Wait(days){
	_date  = {
		start = AIDate.GetCurrentDate(),
		till = AIDate.GetCurrentDate() + days
	};
	return true;
}

function Thread::IsWaiting(){
	if(_date == null) return false;

	if(AIDate.GetCurrentDate() < _date.start){
		return false;
	}

	if(AIDate.GetCurrentDate() > _date.till){
		return false;
	}

	return true;
}

function Thread::WaitAmount(){
	return _date.till - AIDate.GetCurrentDate();
}

function Thread::WakeUp(){
	_ticks = 0;
	_sleep = 0;
	_date = null;
}