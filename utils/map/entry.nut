/**
 * This class is a complex address to define on which side an index is entered
 */
class MapEntry {
    index   = null;
    origin  = null;

    constructor(index, origin){
        this.index	= index;
        this.origin	= origin;
    }
}

function MapEntry:CreateFromTile(from, index){
    return MapEntry(index, Tile.GetDirection(index, from));
}