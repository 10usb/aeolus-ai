require("astar/finder.nut");
require("vectors/finder.nut");

class RailController {
}

function RailController::FoundNewRoute(){
	local astar = RailAstarFinder();

	local locations;
	local point;

	do {
		AILog.Info("Waiting for startpoint");
		locations = Signs.GetNewLocations(2);
	}while(AIMap.DistanceManhattan(locations[0], locations[1])!=1);

	point		= MapPoint();
	point.from	= locations[0];
	point.to	= locations[1];
	point.Print("start:");
	astar.AddStartpoint(point);

	do {
		AILog.Info("Waiting for endpoint");
		locations = Signs.GetNewLocations(2);
	}while(AIMap.DistanceManhattan(locations[0], locations[1])!=1);

	point		= MapPoint();
	point.from	= locations[0];
	point.to	= locations[1];
	point.Print("end:");
	astar.AddEndpoint(point);


	local types = AIRailTypeList();
	types.Valuate(AIRail.IsRailTypeAvailable);
	types.KeepValue(1);
	types.KeepTop(1);
	astar.SetRailTypes(types);

	astar.Init();

	AILog.Info("Searching A*");
	local path = astar.Search();


	local vector = RailVectorsFinder();

	AILog.Info("Parsing to vectors");
	vector.Parse(path);

	//AILog.Info("Optimizing vectors");
	//while(vector.Optimize());

	AILog.Info("Building to vectors");
	vector.Build();
}