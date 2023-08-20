/**
 * This class is able to reference to instances within the OpenTTD eco
 */
class Reference {
	static NONE = 0;
	static INDUSTRY = 1;
	static TOWN = 2;
	static STATION = 3;

    type        = null;
    id          = null;

    constructor(type, id){
        this.type	= type;
        this.id	= id;
    }

    function _tostring(){
        switch(type){
            case INDUSTRY: return "{" + type + ":" + id + ":'" + Industry.GetName(id) + "'}";
            case TOWN: return "{" + type + ":" + id + ":'" + Town.GetName(id) + "'}";
            case STATION: return "{" + type + ":" + id + ":'" + Station.GetName(id) + "'}";
        }
        return "{" + type + ":" + id + "}";
    }

    function GetLocation(){
        switch(type){
            case INDUSTRY: return Industry.GetLocation(id);
            case TOWN: return Town.GetLocation(id);
            case INDUSTATIONSTRY: return Station.GetLocation(id);
        }
    }
}

function Reference::FromTile(tile){
    if(Tile.IsStationTile(tile))
        return Reference(Reference.STATION, Station.GetStationID(tile));

    local id = Industry.GetIndustryID(tile);
    if(Industry.IsValidIndustry(id))
        return Reference(Reference.INDUSTRY, id);

    if(!Tile.IsBuildable(tile) && !Tile.IsCrossable(tile)){
        id = Tile.GetTownAuthority(tile);
        if(Town.IsValidTown(id))
            return Reference(Reference.TOWN, id);
    }

    return null;
}