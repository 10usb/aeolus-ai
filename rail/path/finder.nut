require("node.nut");
require("queue.nut");

class RailPathFinder {
    signs		= null;
	queue		= null;
	nodes		= null;
	

	constructor(){
		this.signs = Signs();
        this.queue = RailPathQueue();
        this.nodes = {};
	}
}

function RailPathFinder::Enqueue(node){
    this.nodes.rawset(node.index, node);
    this.queue.Add(node);

    this.signs.Build(node.index, "" + node.value);
}

function RailPathFinder::Step(){
	if(this.queue.Count() <= 0) return false;
	
    // Poll queue
	local node = this.queue.Poll();
    
    // Test candidates
    foreach(index in node.GetCandidates()){
        // Is index buildable
        if(!Tile.IsBuildable(index))
            continue;
        
        // Get cost value
        local cost = 50 + node.value;
        
        if(node.forerunner){
            // TODO: This needs to be the height of the sides connected to the node
            local indexHeight = Tile.GetMaxHeight(index);
            local destHeight = Tile.GetMinHeight(node.forerunner.index);

            if(indexHeight != destHeight) cost+= 1000;
        }

        // Compare cost to an already existing node
        // If less then replace and add to the queue
        if(this.nodes.rawin(index)){
            local current = this.nodes.rawget(index);

            if(cost < current.value){
                this.Enqueue(RailPathNode(index, node, cost));
            }
        }else{
            this.Enqueue(RailPathNode(index, node, cost));
        }
    }

    return true;
}