class RoadPathQueue {
	instance = null;
	
	constructor(){
		this.instance = FibonacciHeap();
	}
}

function RoadPathQueue::Count(){
	return this.instance.Count();
}

function RoadPathQueue::Add(node){
	return this.instance.Insert(node, node.value + node.extra);
}

function RoadPathQueue::Poll(){
	return this.instance.Pop();
}