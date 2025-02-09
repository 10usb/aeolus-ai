# Project Builders
All builders need to comply with an given assigned budget & additional
funds account. Every builder mind need extra parameters to function
properly.

## Busses/Trucks Builders
- Inner city (town_id, max_stations)
- Inter city (town_ids[], max_stations)
- Industry/station to industry/town/station (source_id, destination_id) 
    * *can be used to transfer from or to*

## Planes
- Inter city (town_ids[])
    * *without this the others can't be build. But should be considers 
    only once*
- Airport (town_id, station_ids[])
- Airport + Busses (town_ids[], station_ids[])

## Ships
- Industry to Industry/Town (source_id, destination_id)
- Inter city (town_ids[])

## Trains
- Inter city
- Industry to Industry/Town

# Analyzers