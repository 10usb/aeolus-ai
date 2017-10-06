class TranslatedTileList extends AITileList {
	constructor(index, x, y){
        ::AIList.constructor();
        AddRectangle(index, AIMap.GetTileIndex(
                AIMap.GetTileX(index) + x,
                AIMap.GetTileY(index) + y
            ));
	}
}