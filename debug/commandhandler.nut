
class CommandHandler {
    _parent = null;
    _commands = null;

    constructor(){
        _commands = {};
    }

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

    function Register(command, callback){
        _commands.rawset(command, {
            name=command
            callback=callback.bindenv(this)
        });
    }

    function OnCommand(command, argument, location){
        local matches = [];
        local length = command.len();

        foreach(name, data in this._commands){
            if(name.len() < length)
                continue;

            if(name.slice(0, length) == command)
                matches.push(data);
        }

        if(matches.len() <= 0){
            Log.Error("Unknown command '" + command + "'");
            this.PrintHelp();
            return true;
        }
        
        if(matches.len() == 1){
            local result = matches[0].callback(argument, location);
            return result == null ? true : result;
        }
        
        Log.Info("Multiple commands matched: " + command);
        foreach(match in matches){
            Log.Info(" - !" + match.name);
        }

        return true;
    }
}