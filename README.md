# Aeolus AI
This is an attempt to create an AI for OpenTTD. I started this a while back, after getting annoyed by the other AI's for not being able to maintain profitable by obvious reasons. Now days it's alot better, but there still not very competitive. And do stuff like building a track over the Mount Everest instead of buildng around it. Thus needing twice as much travel time.

## Goals
Over the time that has passed and many attempts and tests and playing with the other AI's I've build a list of what the AI should be able to do.
- Impliment all transportation types
- Build smooth rail by terraforming the terrain a bit
- Build rail-networks
- Constantly optimizing rail when posible, not leaving bridges over nothing due to other obstruction have gone.
- Having multiple personalities
    - Favor's some goods over others
    - Favor some transportation types over others
    - Build roads or only use existing (thus hijacking routes of other)
    - Try to build centralized or all around the map
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
It once was able to construct airports with planes all by it's self and keep profitable with the maintanance setting on, at least with small airports. The step into large airports takes a toll of more then a couple of millions and there was a 10% chance it survived that transition. So without aid of buses tranfering enough passengers and mail to the airports until the cities have grown around it, it was still hopeless. Then some stuff got refactored in combination with some memory loss of mine..... and it's now broke.

Lately most of my effort goes into making train logic work. It can't do this by it self at the moment. It needs to be instructed to do so with sign posts for commands. For example telling between which 2 industries it has to try to build a functional single track.