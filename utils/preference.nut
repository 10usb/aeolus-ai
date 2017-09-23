class Preference {
	name = null
	preference = null
	rating = null
	favor = null

	constructor(name){
		this.name = name;

		if(Storage.ValueExists(name)){
			local data = Storage.GetValue(name);
			preference = AIList();
			foreach(index, value in data.preference){
				preference.AddItem(index, value);
			}
			rating = AIList();
			foreach(index, value in data.rating){
				rating.AddItem(index, value);
			}
			favor = AIList();
			foreach(index, value in data.favor){
				favor.AddItem(index, value);
			}
			favor.Sort(AIList.SORT_BY_VALUE, false);
		}
	}
}

function Preference::Flush(){
	local data = {
		preference = {},
		rating = {},
		favor = {}
	};
	foreach(index, value in preference){
		data.preference.rawset(index, value);
	}
	foreach(index, value in rating){
		data.rating.rawset(index, value);
	}
	foreach(index, value in favor){
		data.favor.rawset(index, value);
	}
	Storage.SetValue(name, data);
}

function Preference::IsLoaded(){
	return Storage.ValueExists(name);
}

function Preference::Init(list, randomize = true){
	preference = AIList();
	preference.AddList(list);

	if(randomize){
		preference.Valuate(List.RandRangeItem, 1, 1000);
	}
	preference.Sort(AIList.SORT_BY_VALUE, false);

	preference.Valuate(List.GetNormalizeValueTo, preference, List.GetSum(preference), 1000 * preference.Count());
	preference.SetValue(preference.Begin(), preference.GetValue(preference.Begin()) + (1000 * preference.Count()) - List.GetSum(preference));

	rating = AIList();
	rating.AddList(preference);
	rating.Valuate(List.SetValue, 0);

	favor = AIList();
	favor.AddList(preference);
	Flush();
}

function Preference::GetFavored(){
	return favor.Begin();
}

function Preference::GetValues(){
	local list = AIList();
	list.AddList(preference);
	return list;
}

function Preference::GetList(){
	local list = AIList();
	list.AddList(favor);
	list.Sort(AIList.SORT_BY_VALUE, false);
	return list;
}

function Preference::Update(list){
	local addition = AIList();
	addition.AddList(list);
	addition.RemoveList(preference);
	addition.Valuate(List.SetValue, 0);

	local subtraction = AIList();
	subtraction.AddList(preference);
	subtraction.RemoveList(list);

	preference = AIList();
	preference.AddList(list);

	preference.Valuate(List.GetNormalizeValueTo, preference, List.GetSum(preference), 1000 * preference.Count());
	preference.SetValue(preference.Begin(), preference.GetValue(preference.Begin()) + (1000 * preference.Count()) - List.GetSum(preference));

	rating.AddList(addition);
	rating.RemoveList(subtraction);

	favor.AddList(addition);
	favor.RemoveList(subtraction);

	// Now recalculate the favor
	foreach(other_id, value in favor){
		favor.SetValue(other_id, preference.GetValue(other_id) + rating.GetValue(other_id));
	}
	favor.Sort(AIList.SORT_BY_VALUE, false);

	Flush();
}

function Preference::DecreaseFavor(id, percentage = 10){
	// Add 10% of the preference value to the rating
	foreach(other_id, value in preference){
		if(other_id != id){
			rating.SetValue(other_id, rating.GetValue(other_id) + value / 10);
		}
	}

	// Because the sum of rating should always be equal to zero we can substract the difference to lower its value
	rating.SetValue(id, rating.GetValue(id) - List.GetSum(rating));

	// Now recalculate the favor
	foreach(other_id, value in favor){
		favor.SetValue(other_id, preference.GetValue(other_id) + rating.GetValue(other_id));
	}
	favor.Sort(AIList.SORT_BY_VALUE, false);

	Flush();
}

function Preference::IncreaseFavor(id, percentage = 10){
	// Substract 10% of the preference value to the rating
	foreach(other_id, value in preference){
		if(other_id != id){
			rating.SetValue(other_id, rating.GetValue(other_id) - value / 10);
		}
	}

	// Because the sum of rating should always be equal to zero we can substract the difference to raise its value
	rating.SetValue(id, rating.GetValue(id) - List.GetSum(rating));

	// Now recalculate the favor
	foreach(other_id, value in favor){
		favor.SetValue(other_id, preference.GetValue(other_id) + rating.GetValue(other_id));
	}
	favor.Sort(AIList.SORT_BY_VALUE, false);
	Flush();
}