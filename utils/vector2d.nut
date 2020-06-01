class Vector2D {
    x = null;
    y = null;

    constructor(x, y){
        this.x = x;
        this.y = y;
    }

    function difference(vector){
        return Vector2D(vector.x - this.x, vector.y - this.y);
    }

    function normalize(){
        local max = abs(x) > abs(y) ? abs(x) : abs(y);
        x = x / max;
        y = y / max;
        return this;
    }

    function reverse(){
        x = -x;
        y = -y;
        return this;
    }

    function _tostring(){
        return x + "x" + y;
    }
}