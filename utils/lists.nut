
class Lists {
}

// From Admiral AI
function Lists::CallFunction(func, args){
	switch (args.len()) {
		case 0: return func();
		case 1: return func(args[0]);
		case 2: return func(args[0], args[1]);
		case 3: return func(args[0], args[1], args[2]);
		case 4: return func(args[0], args[1], args[2], args[3]);
		case 5: return func(args[0], args[1], args[2], args[3], args[4]);
		case 6: return func(args[0], args[1], args[2], args[3], args[4], args[5]);
		case 7: return func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
		case 8: return func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
		default: throw "Too many arguments to CallFunction";
	}
}

// From Admiral AI
function Lists::Valuate(list, valuator, ...){
	local args = [null];

	for(local c = 0; c < vargc; c++) {
		args.append(vargv[c]);
	}

	// We can't safely alter the values of the list while iterating over it
	// When the list it sorted by value, altering it might lead to an
	// iteration * 2 - 1, Therefore we store the result in a sepparate list
	local result = List();

	foreach(item, _ in list) {
		args[0] = item;
		local value = Lists.CallFunction(valuator, args);
		if (typeof(value) == "bool") {
			value = value ? 1 : 0;
		} else if (typeof(value) != "integer") {
			throw("Invalid return type from valuator");
		}
		result.SetValue(item, value);
	}

	// Now save the values back in the original list
	foreach(item, value in result) {
		list.SetValue(item, value);
	}
}

function Lists::GetSum(list){
	local total = 0;
	foreach(dummy, value in list){
		total+= value;
	}
	return total;
}

function Lists::GetAvg(list){
	local total = 0;
	foreach(dummy, value in list){
		total+= value;
	}
	return total / list.Count();
}

function Lists::Flip(list){
	local flipped = AIList();
	foreach(value, key in list){
		if(!flipped.HasItem(key)){
			flipped.AddItem(key, value);
		}
	}
	return flipped;
}

function Lists::GetMax(list){
	local max = 0;
	foreach(dummy, value in list){
		if(value > max){
			max = value;
		}
	}
	return max;
}

function Lists::SetValue(unsued, value){
	return value;
}

function Lists::GetNormalizeValueTo(index, list, total, max){
	return list.GetValue(index) * max / total;
}

function Lists::RandRangeItem(unused, min, max){
	return min + AIBase.RandRange(AIBase.RandRange(max - min));
}

function Lists::RandPriority(list){
	local max = Lists.GetSum(list);
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

function Lists::GroupByValue(list){
	local groups = {};

	foreach(key, value in list){
		if(!groups.rawin(value)){
			groups.rawset(value, AIList());
		}
		local group = groups.rawget(value);
		group.AddItem(key, value);
	}

	return groups;
}