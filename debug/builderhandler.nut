class BuilderHandler extends CommandHandler {
    source_id = null;
    destination_id = null;
    processor = null;
    loading_station = null;

	constructor(){
	    Log.Info("Build commands");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
        Log.Info(" - !station       Let the search for the station begin");
        Log.Info(" - !path          Builds path of the best option");
    }
    
    function OnCommand(command, sign_id){
        if(command == "!exit"){
            AISign.RemoveSign(sign_id);
            return false;
        }else if(command == "!source" || command == "!destination"){
            local location = AISign.GetLocation(sign_id);
            AISign.RemoveSign(sign_id);

            local industry_id = Industry.GetIndustryID(location);

            if(!Industry.IsValidIndustry(industry_id)){
                Log.Info("No industry found");
            }else{
                if(command == "!source"){
                    this.source_id = industry_id;
                    Log.Info("Source: " + Industry.GetName(industry_id));
                }else{
                    this.destination_id = industry_id;
                    Log.Info("Destination: " + Industry.GetName(industry_id));
                }
            }
        }else if(command == "!station"){
            AISign.RemoveSign(sign_id);
            BuildSourceStation();
        }else if(command == "!path"){
            AISign.RemoveSign(sign_id);
            BuildPath();
        }
        return true;
    }

    function BuildSourceStation(){
        this.loading_station = RailLoadingStation(source_id, Industry.GetLocation(destination_id), 4, 35);
        this.GetParent().EnqueueTask(this.loading_station);
    }
    
    function BuildPath(){
        local path = loading_station.best.finder.GetPath();
        this.processor = RailPathBuilder();

        this.GetParent().EnqueueTask(RailPathExtender(path, Industry.GetLocation(this.destination_id), 35, this.processor));
    }
}