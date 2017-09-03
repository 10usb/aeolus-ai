class Preference {
	preference = null
	rating = null
	favor = null


	constructor(list){
		preference = AIList();
		preference.AddList(list);

		preference.Valuate(List.RandRangeItem, 1, 1000);
		preference.Sort(AIList.SORT_BY_VALUE, false);

		preference.Valuate(List.GetNormalizeValueTo, preference, List.GetSum(preference), 1000 * preference.Count());
		preference.SetValue(preference.Begin(), preference.GetValue(preference.Begin()) + (1000 * preference.Count()) - List.GetSum(preference));

		rating = AIList();
		rating.AddList(preference);
		rating.Valuate(List.SetValue, 0);

		favor	= AIList();
		favor.AddList(preference);
	}
}

function Preference::GetFavored(){
	return favor.Begin();
}

function Preference::GetValues(){
	local list = AIList();
	list.AddList(preference);
	return list;
}

function Preference::DecreaseFavor(id){
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
}

function Preference::IncreaseFavor(id){
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
}