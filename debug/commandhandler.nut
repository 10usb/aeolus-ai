
class CommandHandler {
    _parent = null;

    function GetParent(){
        return this._parent;
    }

    function SetParent(task){
        this._parent = task;
    }

    function EnqueueTask(task){
        this._parent.EnqueueTask(task);
    }

    function PrintHelp();

    function OnCommand(command, location);
}