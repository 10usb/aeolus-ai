class TranslatedTileList extends AITileList {
    constructor(index, x, y, sx = 0, sy = 0){
        ::AIList.constructor();
        AddRectangle(AIMap.GetTileIndex(
                AIMap.GetTileX(index) + sx,
                AIMap.GetTileY(index) + sy
            ), AIMap.GetTileIndex(
                AIMap.GetTileX(index) + x,
                AIMap.GetTileY(index) + y
            ));
    }
}