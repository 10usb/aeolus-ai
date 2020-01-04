
class CommandHandler {
    _parent = null;

    function GetParent(){
        return this._parent;
    }

    function SetParent(task){
        this._parent = task;
    }

    function OnCommand(command, sign_id);
}