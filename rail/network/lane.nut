/**
 * A lane is a piece of rail with no inteference that might allow traffic only
 * in a single direction
 */
class RailNetworkLane {
    index = null; // A MapEntry
    terminal = null; // A lane object
    blocked = false; // Does is allow trains going in
    length = 0; // The number of tiles
}