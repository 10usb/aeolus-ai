class DefaultHandler extends CommandHandler {
    debugging = null;

	constructor(debugging){
        ::CommandHandler.constructor();
        this.debugging = debugging;
        this.Register("constructor", this.OnConstructor);
        this.Register("finder", this.OnFinder);
        this.Register("vector", this.OnVector);
        this.Register("builder", this.OnBuilder);
        this.Register("segments", this.OnSegments);
        this.Register("test", this.OnTest);
    }

    function PrintHelp(){
        Log.Info("Debugging commands:");
        Log.Info(" - !exit          To return to the default handler");
        Log.Info(" - !help          To print the help of the current handler");
        Log.Info(" - !clear         Clear all signal posts");
        Log.Info(" - !finder        To find a path");
        Log.Info(" - !vector        Use vectors to build rail");
        Log.Info(" - !builder       Start the builder");
        Log.Info(" - !segments      Segments & vectors");
        Log.Info(" - !constructor   Segments & vectors");
    }

    function OnConstructor(argument, location){
        this.debugging.SetHandler(DebugConstructorHandler());
    }

    function OnFinder(argument, location){
        this.debugging.SetHandler(FinderHandler());
    }

    function OnVector(argument, location){
        this.debugging.SetHandler(VectorHandler());
    }

    function OnBuilder(argument, location){
        this.debugging.SetHandler(BuilderHandler());
    }

    function OnSegments(argument, location){
        this.debugging.SetHandler(SegmentHandler());
    }

    function OnTest(argument, location){
        this.debugging.SetHandler(DebugTestHandler());
    }
}