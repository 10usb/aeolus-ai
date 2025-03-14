class Task {
	_thread = null;
	_ticks = 0;
	_sleep = 0;
	_date  = null;

	function Run();
	function GetName();

	function SetThread(thread){
		this._thread = thread;
		return this;
	}

	function PushTask(task, result = true){
		this._thread.Push(task);
		if(!result)
			this._thread.Remove(this);
		return task;
	}

	function EnqueueTask(task){
		_thread.scheduler.EnqueueTask(task);
	}

	function GetParent(){
		return this;
	}

	function Sleep(ticks){
		_ticks = Controller.GetTick();
		_sleep = ticks;
		return true;
	}

	function IsSleepy(){
		if(Controller.GetTick() < _ticks){
			return false;
		}
		if(Controller.GetTick() >= (_ticks + _sleep)){
			return false;
		}
		return true;
	}

	function SleepAmount(){
		return (_ticks + _sleep) - Controller.GetTick();
	}

	function Wait(days){
		_date  = {
			start = AIDate.GetCurrentDate(),
			till = AIDate.GetCurrentDate() + days
		};
		return true;
	}

	function WaitUntil(date){
		_date  = {
			start = AIDate.GetCurrentDate(),
			till = date
		};
		return true;
	}

	function IsWaiting(){
		if(_date == null) return false;

		if(AIDate.GetCurrentDate() < _date.start){
			return false;
		}

		if(AIDate.GetCurrentDate() > _date.till){
			return false;
		}

		return true;
	}

	function WaitAmount(){
		if(_date == null) return 0;
		return _date.till - AIDate.GetCurrentDate();
	}

	function WakeUp(){
		if(_sleep > 0 || _date != null){
			_ticks = 0;
			_sleep = 0;
			_date = null;
			return true;
		}
		return false;
	}
}