# Aeolus AI
This is an attempt to create an AI for OpenTTD. After being annoyed by the other AI's for not being able to maintain profitable by obvious reasons.

## Goals
- Impliment all transportation types
- Build smooth rail by terraforming the terrain a bit
- Build rail-networks
- Optimizing rail-networks when posible, not leaving bridges over nothing due to other obstruction have gone
- Having mutiple personalities
    - Favor's some goods over others
    - Favor some transportation types over others
    - Build roads or only use existing (thus hijacking routes of other)
    - Try to build centralized or all around
    - Build rail networks or all single track routes
    - Play fair or try to make other players broke
- Combine multiple transportation types using the transfer feature
    - Trains with boats for crossing lakes
    - Using buses to transport passengers from nearby cities to the airport. To make a (new) airport profitable when maintanance is on (and city is not yet build around it, thus not supplying enough)
    - Using buses to transport passengers from nearby cities to train-station to up the profit
    - Using buses/trucks to transport cargo from mountain top to the mountain foot and use trains to up the profit
    - Using trucks with multiple stations to have a larger share of the cargo generated when multiple players transport from the same source, and using trains to up the profit
- Invest by building roads in cities to make them grow around a station or aiport faster
- Invest in coastal cities by expanding land into sea with islands

## What can it do
At the moment it's able to build when instructed to by using the sign posts for commands. It once was able to construct airports with planes all by it's self and keep profitable with maintanance setting on. At least with small airports, the step into large airports takes a toll of more then a couple of millions and there was a 10% change it survived that. So without aid of buses tranfering enough passengers and mail to the airports until the cities have grown around it, it was still hopeless. Then some stuff got refactored in combination with some memory loss of mine..... and it's now broke. Lately most of my effort goes into making trains work.