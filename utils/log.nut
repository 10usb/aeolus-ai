class Log extends AILog {
}


function Log::Dump(object, prefix = "", suffix = "", tabs = ""){
    switch(typeof(object)){
        case "string":
        case "float":
        case "integer":
            Log.Info(tabs + prefix + typeof(object) + "(" + object + ")" + suffix);
        break;
        case "table":
            Log.Info(tabs + prefix + "table {");
            foreach(key, value in object){
                Log.Dump(value, key + " = ", ",", tabs + "    ");
            }
            Log.Info(tabs + "}" + suffix);
        break;
        case "array":
            Log.Info(tabs + prefix + "array [");
            foreach(key, value in object){
                Log.Dump(value, key + " = ", ",", tabs + "    ");
            }
            Log.Info(tabs + "]" + suffix);
        break;
        default:
            if(object instanceof ::AIList){
                Log.Info(tabs + prefix + "AIList {");
                foreach(key, value in object){
                    Log.Dump(value, key + " = ", ",", tabs + "    ");
                }
                Log.Info(tabs + "}" + suffix);
            }else{
                Log.Info(tabs + prefix + typeof(object));
            }
        break;
    }
}