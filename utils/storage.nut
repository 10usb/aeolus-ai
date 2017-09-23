class Storage {
	static values = {};
}

function Storage::ValueExists(key){
	return Storage.values.rawin(key) ? 1 : 0;
}

function Storage::GetValue(key){
	if(Storage.values.rawin(key)) return Storage.values.rawget(key);
	throw("Unknown storage key \"" + key + "\"");
}

function Storage::SetValue(key, value){
	Storage.values.rawset(key, value);
	return value;
}