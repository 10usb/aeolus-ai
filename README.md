# Aeolus AI
An attempt to create an AI for OpenTTD

## Todo
- Check for aircrafts not making enough money
- Check for aiports not having enough aircrafts to support the maintanance cost
- Make a Budget for aircrafts in need for replacement before actualy trying to replace it
- Better check if an opportunity at a town has enough cargo at the location the station is build
- When searching for/trying to build opportunities check if airports are not full and add aircraft with that cargo

## Transport Profiles
- Passenger Planes (Town to Town)
  - Find oppertunity #1
    - Make a list of best plane engines for each range given 100 days of travel
    - Find city engine pair with capacity to support maintanance of airport (some idjit
      set the default maintanance setting to 0)
    - Test if airport supported by engine type can be build with enough houses that are
      not in range of other stations
    - Select best 3
    - Find destinations
      - Find stations in reach with over capacity of planes
      - Find stations in reach with over capacity of cargo
      - Find town with enough capacity to support the shared maintanance of the airports
  - Find oppertunity #2
    - Find airports that have room for more planes to land and don't transport passengers
    - Find destinations
      - Find stations in reach with over capacity of planes
      - Find airports that have room for more planes to land and don't transport passengers
      - Find stations in reach with over capacity of cargo
  - Builder
    - Select best payable oppertunity
    - Test if oppertunity is still profitable
    - Build Airport(s) (#1)
    - Redirect planes from other stations (#1, #2)
    - Add planes until capacity limit of cargo or number of planes is reached (#1, #2)
  - Manage Airports
    - Check if planes can be added
    - Check if connected planes don't make enough money to support the maintanace cost
      - Find new destination for planes
      - Sell airport
    - Check if a newer (larger) airport can be build and connected planes maken enough
      money to support the maintanace cost
      - Start making space and claiming land for side of new airport
      - Build new airport
  - Manage Planes
    - Check if 70% of age
      - Send to load of cargo
      - Send to depot
      - Replace or upgrade or delete if airport not supports
    - Check if profit made
      - Find alternate route
      - Send to depot to sell
- Mail Planes (Town to Town)
  - @see Passenger Planes
- Passenger Helicopters (Industry to Town)
- Passenger Buses (Town to Town)
  - @see Passenger Planes for idea
- Passenger Buses (Industry to Town)
- Mail Buses (Town to Town)
  - @see Passenger Planes for idea
- Fraight Trucks (Industry to Industry)
- Fraight Trucks (Industry to Industry, Hijack routes)
- Fraight Trucks (Industry to Town)
- Passenger & Mail Trains (Town to Town)
- Fraight Trains (Industry to Industry)
- Fraight Trains (Industry to Town)
- Farries (Town to Town)
- Farries (Industry to Town)
- Oiltanker (Industry to Industry)
- Cargoship (Industry to Industry)
- Cargoship (Industry to Town)