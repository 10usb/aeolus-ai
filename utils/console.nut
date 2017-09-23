class Console {
}


function Console::Dump(object, prefix = "", suffix = "", tabs = ""){
    switch(typeof(object)){
        case "string":
        case "float":
        case "integer":
            AILog.Info(tabs + prefix + typeof(object) + "(" + object + ")" + suffix);
        break;
        case "table":
            AILog.Info(tabs + prefix + "table {");
            foreach(key, value in object){
                Console.Dump(value, key + " = ", ",", tabs + "    ");
            }
            AILog.Info(tabs + "}" + suffix);
        break;
        default:
            AILog.Info(tabs + prefix + typeof(object));
        break;
    }
}