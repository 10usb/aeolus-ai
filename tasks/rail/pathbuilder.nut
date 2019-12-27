class RailPathBuilder extends Task {
    path = null;
    index = 0;
    signs = null;
    railType = null;

	constructor(path){
        this.path = path;
        this.index = 0;
        this.signs = Signs();
	}
}

function RailPathBuilder::GetName(){
    return "RailPathBuilder"
}

function RailPathBuilder::Run(){
    if(this.index >= this.path.len()) {
        signs.Clean();
        return false;
    }

    if(index == 0){
        local types = AIRailTypeList();
        types.Valuate(Rail.IsRailTypeAvailable);
        types.KeepValue(1);
        railType = types.Begin();   
        index++;     
        return true;
    }

    Rail.SetCurrentRailType(railType);
    for(local count = 0; count < 10 && this.index + 1 < this.path.len(); count++){
        // this.signs.Build(this.path[this.index], "" + this.index);

        Rail.BuildRail(this.path[this.index - 1], this.path[this.index], this.path[this.index + 1]);
        this.index++;
    }

    if(this.index < this.path.len()) return true;
    return this.Sleep(100);
}