class RailPathBuilder extends Task {
    path = null;
    index = 0;
    signs = null;

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
        types.Valuate(AIRail.IsRailTypeAvailable);
        types.KeepValue(1);
        AIRail.SetCurrentRailType(types.Begin());

        return true;
    }

    for(local count = 0; count < 10 && this.index < this.path.len(); count++){
        this.signs.Build(this.path[this.index++], "" + this.index);
    }

    if(this.index < this.path.len()) return true;
    return this.Sleep(100);
}