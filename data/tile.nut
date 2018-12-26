class Tile extends AITile {
	constructor(){
	}
}

function Tile::GetTranslatedIndex(index, x, y){
	return AIMap.GetTileIndex(
            AIMap.GetTileX(index) + x,
            AIMap.GetTileY(index) + y
        );
}

function Tile::IsCrossable(index){
    return AIRoad.IsRoadTile(index) || AIRail.IsRailTile(index) || Tile.IsWaterTile(index);
}