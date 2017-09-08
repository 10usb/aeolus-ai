class Town extends AITown {
}

function Town::GetAirportCount(town_id){
	local stations = AIStationList(AIStation.STATION_AIRPORT);
	stations.Valuate(AIStation.GetNearestTown);
	stations.KeepValue(town_id);
	return stations.Count();
}

function Town::GetDaysTravel(town_id, tile, speed){
	return (Math.sqrt(AITown.GetDistanceSquareToTile(town_id, tile)) * 44.3 / speed).tointeger();
}

function Town::GetAvailableCargo(town_id, cargo_id){
	return AITown.GetLastMonthProduction(town_id, cargo_id) - AITown.GetLastMonthSupplied(town_id, cargo_id);
}

function Town::CanBuildAirport(town_id){
	return 1;
}

function Town::GetDistanceToTile(town_id, tile){
	return sqrt(Town.GetDistanceSquareToTile(town_id, tile)).tointeger();
}

function Town::GetTiles(type = null, expand = 0){
	local list = AIList();
	local outer = AIList();
	local queue = [];

	list.AddItem(AITown.GetLocation(this.id), 0);
	queue.push(AITown.GetLocation(this.id));

	while(queue.len()){
		local tile = queue[0];
		queue.remove(0);

		local test = null;

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile) + 1, AIMap.GetTileY(tile));
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, this.id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile) - 1, AIMap.GetTileY(tile));
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, this.id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) + 1);
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, this.id)){
				list.AddItem(test, 0);
				queue.push(test);
			}else if(!outer.HasItem(test)){
				outer.AddItem(test, 0);
			}
		}

		test = AIMap.GetTileIndex(AIMap.GetTileX(tile), AIMap.GetTileY(tile) - 1);
		if(!list.HasItem(test)){
			if(AITile.IsWithinTownInfluence(test, this.id)){
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






function Town::BuildAirport(cargo_id, small, budget){
	this.airport_build = AIDate.GetCurrentDate();
	local airport_type = AirPort.GetBestType(small);
	local list = this.GetTiles(true, Math.max(AIAirport.GetAirportWidth(airport_type), AIAirport.GetAirportHeight(airport_type)));

	list.Valuate(AITile.IsBuildableRectangle, AIAirport.GetAirportWidth(airport_type), AIAirport.GetAirportHeight(airport_type));
	list.KeepValue(1);

	list.Valuate(AIAirport.GetNoiseLevelIncrease, airport_type);
	list.RemoveAboveValue(AITown.GetAllowedNoise(this.id));

	list.Valuate(AITile.GetCargoProduction, cargo_id, AIAirport.GetAirportWidth(airport_type), AIAirport.GetAirportHeight(airport_type), AIAirport.GetAirportCoverageRadius(airport_type));
	list.Sort(AIList.SORT_BY_VALUE, false);
	list.KeepTop(Math.max(5, list.Count() / 4));

	foreach(tile, value in list){
		if(Town.TryBuildAirport(tile, airport_type, budget)){
			return tile;
		}
	}
	return false;
}

function Town::TryBuildAirport(tile, airport_type, budget){
	local matrix = MapMatrix();
	matrix.AddRectangle(tile, AIAirport.GetAirportWidth(airport_type), AIAirport.GetAirportHeight(airport_type));
	if(!matrix.Level()){
		return false;
	}

	local cost = matrix.GetCosts();

	if(cost > budget) return false;
	if(!Finance.GetMoney(cost)) return false;
	local accounting = AIAccounting();
	matrix.MakeLevel();

	if(!Finance.GetMoney(AIAirport.GetPrice(airport_type) * 1.1)) return false;
	return AIAirport.BuildAirport(tile, airport_type, AIStation.STATION_NEW);
}
