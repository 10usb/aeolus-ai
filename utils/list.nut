
class List {
}

function List::GetSum(list){
	local total = 0;
	foreach(dummy, value in list){
		total+= value;
	}
	return total;
}

function List::GetMax(list){
	local max = 0;
	foreach(dummy, value in list){
		if(value > max){
			max = value;
		}
	}
	return max;
}

function List::SetValue(unsued, value){
	return value;
}

function List::GetNormalizeValueTo(index, list, total, max){
	return list.GetValue(index) * max / total;
}

function List::RandRangeItem(unused, min, max){
	return min + AIBase.RandRange(AIBase.RandRange(max - min));
}

function List::RandPriority(list){
	local max = List.GetSum(list) - 1;
	if(max <= 0){
		return list.Begin();
	}

	local target = AIBase.RandRange(max);
	local total = 0;
	foreach(index, value in list){
		if((total + value) > target){
			return index;
		}
		total+= value;
	}

	throw("Internal error");
}