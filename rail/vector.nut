class RailVector {
	static ORIGIN_INVALID = 4;
    static ORIGIN_NW = 0;
    static ORIGIN_NE = 1;
    static ORIGIN_SE = 2;
    static ORIGIN_SW = 3;

    static DIRECTION_LEFT = -1;
    static DIRECTION_STRAIGHT = 0;
    static DIRECTION_RIGHT = 1;

    static PITCH_UP = 1;
    static PITCH_LEVEL = 0;
    static PITCH_DOWN = -1;
    
	origin	    = 0; // SE, SW, NW, NE
	direction   = 0; // left, straight, right
    pitch	    = 0; // up, level, down
    length      = 0; // number of rail parts
}