class RailAstarQueue {
	instance = null;
	
	constructor(){
		this.instance = FibonacciHeap();
	}
}

function RailAstarQueue::Count(){
	return this.instance.Count();
}

function RailAstarQueue::Add(node){
	return this.instance.Insert(node, node.value);
}

function RailAstarQueue::Poll(){
	return this.instance.Pop();
}
