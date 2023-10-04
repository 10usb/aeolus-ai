class Road extends AIRoad {

}

function Road::GetConnectedSides(tile){
    local side = 0;

    if(Road.AreRoadTilesConnected(tile, Tile.GetTranslatedIndex(tile, 1, 0)))
        side = side | Tile.SIDE_SW;

    if(Road.AreRoadTilesConnected(tile, Tile.GetTranslatedIndex(tile, -1, 0)))
        side = side | Tile.SIDE_NE;

    if(Road.AreRoadTilesConnected(tile, Tile.GetTranslatedIndex(tile, 0, 1)))
        side = side | Tile.SIDE_SE;

    if(Road.AreRoadTilesConnected(tile, Tile.GetTranslatedIndex(tile, 0, -1)))
        side = side | Tile.SIDE_NW;

    return side;
}

function Road::GetRoadTracks(tile){
    local side = Road.GetConnectedSides(tile);
    local tracks = 0;

    if((side & Tile.SIDE_NE) != 0){
        // Straight x-axis
        if((side & Tile.SIDE_SW) != 0) tracks = tracks | Rail.RAILTRACK_NE_SW;

        // Top
        if((side & Tile.SIDE_NW) != 0) tracks = tracks | Rail.RAILTRACK_NW_NE;
        // Right
        if((side & Tile.SIDE_SE) != 0) tracks = tracks | Rail.RAILTRACK_NE_SE;
    }
    if((side & Tile.SIDE_NW) != 0){
        // Straight y-axis
        if((side & Tile.SIDE_SE) != 0) tracks = tracks | Rail.RAILTRACK_NW_SE;
        // Left
        if((side & Tile.SIDE_SW) != 0) tracks = tracks | Rail.RAILTRACK_NW_SW;
    }
    if((side & Tile.SIDE_SW) != 0){
        // Bottom
        if((side & Tile.SIDE_SE) != 0) tracks = tracks | Rail.RAILTRACK_SW_SE;
    }

    return tracks;
}