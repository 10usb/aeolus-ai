class Cache {
	static values = {};
}

function Cache::ValueExists(key){
	return Cache.values.rawin(key) ? 1 : 0;
}

function Cache::GetValue(key){
	if(Cache.values.rawin(key)) return Cache.values.rawget(key);
	throw("Unknown cache key \"" + key + "\"");
}

function Cache::SetValue(key, value){
	Cache.values.rawset(key, value);
	return value;
}