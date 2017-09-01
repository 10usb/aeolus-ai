class RailPathQueue {
	instance = null;
	
	constructor(){
		this.instance = FibonacciHeap();
	}
}

function RailPathQueue::Count(){
	return this.instance.Count();
}

function RailPathQueue::Add(node){
	return this.instance.Insert(node, node.extra);
}

function RailPathQueue::Poll(){
	return this.instance.Pop();
}