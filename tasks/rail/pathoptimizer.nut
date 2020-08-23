/**
 * This rail processor task will try to optimize the path received before
 * constructing it. First it will transform the array of tiles into vectors.
 * These vectors can then be aligned opon each other and tested. Thus removeing
 * the vectors inbetween, giving a more smooth rail.
 */
class RailPathOptimizer extends Task {
    railType = null;
    vectorizer = null;
    builder = null;
    state = null;
    current = null;
    finalized = null;
    
	constructor(railType){
        this.railType = railType;
        this.vectorizer = RailPathVectorizer();
        this.builder = null;
        this.state = 0;
        this.current = null;
        this.finalized = false;
	}

    function GetName(){
        return "RailPathOptimizer";
    }

    function Append(path){
        this.vectorizer.Append(path);

        if(this.state == 0){
            this.state = 1;
        }
    }

    function Finalize(){
        this.LoadBuilder();
        this.builder.Finalize();
        this.finalized = true;
    }

    function Run(){
        if(this.state == 1){
            this.PushTask(this.vectorizer);
            this.state = 2;
            return true;
        }

        if(this.state == 2){
            this.LoadBuilder();
            local queue = TaskQueue();
            queue.EnqueueTask(RailVectorOptimizer(this.builder.GetNext(), this.finalized));
            queue.EnqueueTask(this.builder);
            this.PushTask(queue);
            this.state = 0;
            return true;
        }

        return false;
    }

    function LoadBuilder(){
        if(this.builder == null){
            this.builder = RailSegmentBuilder(this.railType, this.vectorizer.GetRoot(), false, 20);
        }
    }
}