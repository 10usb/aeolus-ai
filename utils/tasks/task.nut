class Task {
	_parent = null;
	_ticks = 0;
	_sleep = 0;
	_date  = null;
	function Run();
	function GetName();
}

function Task::GetParent(){
	return _parent;
}

function Task::Sleep(ticks){
	_ticks = Controller.GetTick();
	_sleep = ticks;
	return true;
}

function Task::IsSleepy(){
	if(Controller.GetTick() < _ticks){
		return false;
	}
	if(Controller.GetTick() >= (_ticks + _sleep)){
		return false;
	}
	return true;
}

function Task::SleepAmount(){
	return (_ticks + _sleep) - Controller.GetTick();
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
	if(_sleep > 0 || _date != null){
		_ticks = 0;
		_sleep = 0;
		_date = null;
		return true;
	}
	return false;
}