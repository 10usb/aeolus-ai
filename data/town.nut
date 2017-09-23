class Town extends AITown {
}

function Town::GetDaysTravel(town_id, tile, speed){
	return (Math.sqrt(AITown.GetDistanceSquareToTile(town_id, tile)) * 44.3 / speed).tointeger();
}

function Town::GetAvailableCargo(town_id, cargo_id){
	return AITown.GetLastMonthProduction(town_id, cargo_id) - AITown.GetLastMonthSupplied(town_id, cargo_id);
}

function Town::GetDistanceToTile(town_id, tile){
	return sqrt(Town.GetDistanceSquareToTile(town_id, tile)).tointeger();
}

function Town::GetTiles(town_id, type = null, expand = 0){
	local list = AIList();
	local outer = AIList();
	local queue = [];

	list.AddItem(AITown.GetLocation(town_id), 0);
	queue.push(AITown.GetLocation(town_id));

	while(queue.len()){
		local tile = queue[0];
		queue.remove(0);

		local test = null;

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile) + 1, AIMap.GetTileY(tile));
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, town_id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile) - 1, AIMap.GetTileY(tile));
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, town_id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) + 1);
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, town_id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) - 1);
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, town_id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}
	}

	if(type==false) return outer;
	if(type==true){
		list.AddList(outer);
		while(expand > 0) {
			expand--;

			foreach(tile, dummy in outer){
				queue.push(tile);
			}
			outer.Clear();

			while(queue.len()){
				local tile = queue[0];
				queue.remove(0);

				local test = null;

				test = AIMap.GetTileIndex(AIMap.GetTileX(tile) + 1, AIMap.GetTileY(tile));
				if(!list.HasItem(test) && !outer.HasItem(test)){
					outer.AddItem(test, 0);
				}

				test = AIMap.GetTileIndex(AIMap.GetTileX(tile) - 1, AIMap.GetTileY(tile));
				if(!list.HasItem(test) && !outer.HasItem(test)){
					outer.AddItem(test, 0);
				}

				test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) + 1);
				if(!list.HasItem(test) && !outer.HasItem(test)){
					outer.AddItem(test, 0);
				}

				test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) - 1);
				if(!list.HasItem(test) && !outer.HasItem(test)){
					outer.AddItem(test, 0);
				}
			}

			list.AddList(outer);
		}
	}
	return list;
}