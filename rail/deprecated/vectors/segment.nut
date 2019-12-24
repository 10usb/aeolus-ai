class RailVectorsSegment {
	vector	= null;
	next	= null;

	constructor(){
		next = null;
	}
}

function RailVectorsSegment::Print(){
	this.vector.ToPoint().Print("v:");
	this.vector.GetPoint().Print();
}

function RailVectorsSegment::Find(limit){
	if(this.next==null) return null;

	local current = this.next.next;
	while(limit-- > 0 && current && current.vector.offset==this.vector.offset){
		current = current.next;
	}
	return current;
}