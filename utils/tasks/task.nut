class Task {
	_parent = null;
	_ticks = 0;
	_sleep = 0;
	_date  = null;
	function Run();
	function GetName();
}

function Task::Sleep(ticks){
	_ticks = Aeolus.GetTick();
	_sleep = ticks;
	return true;
}

function Task::IsSleepy(){
	if(Aeolus.GetTick() < _ticks){
		return false;
	}
	if(Aeolus.GetTick() >= (_ticks + _sleep)){
		return false;
	}
	return true;
}

function Task::SleepAmount(){
	return (_ticks + _sleep) - Aeolus.GetTick();
}

function Task::Wait(days){
	_date  = {
		start = AIDate.GetCurrentDate(),
		till = AIDate.GetCurrentDate() + days
	};
	return true;
}

function Task::IsWaiting(){
	if(_date == null) return false;

	if(AIDate.GetCurrentDate() < _date.start){
		return false;
	}

	if(AIDate.GetCurrentDate() > _date.till){
		return false;
	}

	return true;
}

function Task::WaitAmount(){
	return _date.till - AIDate.GetCurrentDate();
}

function Task::WakeUp(){
	_ticks = 0;
	_sleep = 0;
	_date = null;
}