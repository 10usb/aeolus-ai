class Math {
}
function Math::abs(value){
	return abs(value);
}
function Math::min(a, b){
	return a < b ? a : b;
}
function Math::max(a, b){
	return a > b ? a : b;
}
function Math::sqrt(value){
	return sqrt(value);
}
function Math::floor(value){
	return floor(value).tointeger();
}
function Math::ceil(value){
	return ceil(value).tointeger();
}
function Math::round(value){
	local f = floor(value);
	if((value - f) >= 0.5) return (f + 1).tointeger();
	return f.tointeger();
}