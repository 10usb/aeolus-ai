class BuilderHandler extends CommandHandler {
    source_id = null;
    destination_id = null;

	constructor(){
	    Log.Info("Build commands");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
        Log.Info(" - !go            Start connecting the source to the destination");
    }

    function PrintHelp(){
	    Log.Info("Build commands");
        Log.Info(" - !source        Set source industry");
        Log.Info(" - !destination   Set destination industry");
        Log.Info(" - !go            Start connecting the source to the destination");
    }
    
    function OnCommand(command, argument, location){
        if(command == "source" || command == "destination"){
            local industry_id = Industry.GetIndustryID(location);

            if(!Industry.IsValidIndustry(industry_id)){
                Log.Info("No industry found");
            }else{
                if(command == "source"){
                    this.source_id = industry_id;
                    Log.Info("Source: " + Industry.GetName(industry_id));
                }else{
                    this.destination_id = industry_id;
                    Log.Info("Destination: " + Industry.GetName(industry_id));
                }
            }
        }else if(command == "go"){
            local types = AIRailTypeList();
            types.Valuate(Rail.IsRailTypeAvailable);
            types.KeepValue(1);
            local railType = types.Begin();

            this.GetParent().EnqueueTask(RailSingleTrack(this.source_id, this.destination_id, 4, railType));
        }
        return true;
    }
}