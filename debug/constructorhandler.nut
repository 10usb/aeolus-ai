class DebugConstructorHandler extends CommandHandler {
    builder = null;
    cargos = null;
    sources = null;
    destinations = null;
    budget = null;
    max = null;

	constructor(){
        this.sources = [];
        this.destinations = [];
        this.cargos = [];
        this.budget = 100000;
        this.max = 100;
    }

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !builder=?     Set the builder to use");
        Log.Info("    - rc          Road inner city");
        Log.Info("    - ric         Road inter city");
        Log.Info("    - rsd         Road source/destination");
        Log.Info(" - !source        Add a source");
        Log.Info(" - !destination   Add a destination");
        Log.Info(" - !show          Show current settings");
        Log.Info(" - !budget=?      Set the budget for the construction");
        Log.Info(" - !max=?         Set the maximum stations allowed");
        Log.Info(" - !cargo=?       Add a cargo to transport");
        Log.Info(" - !go            Start the builder with the current settings");
    }
    
    function OnCommand(command, argument, location){
        switch(command){
            case "builder": this.SetBuilder(argument); break;
            case "cargo": this.AddCargo(argument); break;
            case "source":
                local source = Reference.FromTile(location);
                if(source!= null){
                    Log.Info("Added source to: " + source);
                    this.sources.push(source);
                }
            break;
            case "destination":
                local destination = Reference.FromTile(location);
                if(destination!= null){
                    Log.Info("Added destination to: " + destination);
                    this.destinations.push(destination);
                }
            break;
            case "budget": this.budget = argument.tointeger(); break;
            case "max": max = argument.tointeger(); break;
            case "show": this.Show(); break;
            case "go": return !this.Go();
            default:
                Log.Error("Unknown command");
                this.PrintHelp();
        }

        return true;
    }
    
    function SetBuilder(argument){
        switch(argument){
            case "rc":
                this.builder = argument;
                Log.Info("Set builder: " + this.GetBuilderName(argument));
            break;
            default:
                Log.Warning("Unknown builder: " + argument);
        }
    }

    function GetBuilderName(code){
        switch(code){
            case "rc": return "Road Inner City";
        }
        return code;
    }
    
    function AddCargo(argument){
        if(argument == "?"){
            Log.Info("Cargo's:");

            foreach(cargo_id, dummy in AICargoList()){
                Log.Info(" - " + cargo_id + " => " + Cargo.GetName(cargo_id));
            }
        }else{
            local cargo_id = argument.tointeger();
            if(!Cargo.IsValidCargo(cargo_id)){
                Log.Warning("Unknown cargo: " + cargo_id);
            }else{
                Log.Info("Added " + Cargo.GetName(cargo_id) + " (" + cargo_id + ")");
                this.cargos.push(cargo_id);
            }
        }
    }

    function Show(){
        Log.Warning("==========================");
        Log.Info("Cargo's:");
        foreach(cargo_id in this.cargos){
            Log.Info(" - " + cargo_id + " => " + Cargo.GetName(cargo_id));
        }
        Log.Info("Sources:");
        foreach(reference in this.sources){
            Log.Info(" - " + reference);
        }

        Log.Info("Destinations:");
        foreach(reference in this.destinations){
            Log.Info(" - " + reference);
        }
        
        Log.Info("Builder: " + this.GetBuilderName(this.builder));
        Log.Info("Budget: " + this.budget);
        Log.Info("Max. Stations: " + this.max);
        Log.Warning("==========================");
    }

    function Go(){
        switch(this.builder){
            case "rc": return this.BuildRoadInnerCity(); break;
            default:
                Log.Warning("Unknown builder: " + this.builder);
        }

        return false;
    }

    function BuildRoadInnerCity(){
        local town_id = null;

        foreach(reference in this.sources){
            if(reference.type == Reference.TOWN){
                town_id = reference.id;
                break;
            }
        }

        if(town_id == null){
            Log.Warning("No source town selected");
            return false;
        }

        if(this.cargos.len()<=0){
            Log.Warning("No cargo selected");
            return false;
        }

        local budget_id = Company.GetInvestmentBudget();
        local funds_id = Company.GetInvestmentBudget();
        local cargo_id = this.cargos[0];

        Log.Info("Town: " + Town.GetName(town_id));
        Log.Info("Cargo: " + Cargo.GetName(cargo_id));
        Log.Info("Budget: " + this.budget);
        Log.Info("Max. Stations: " + this.max);
        
        local task = Tasks_Road_BuildInnerCity(budget_id, funds_id, cargo_id, town_id, this.max);
        this.EnqueueTask(task);

        return true;
    }
}