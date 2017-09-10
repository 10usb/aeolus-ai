
class AirStationManager extends Thread {
}

function AirStationManager::Run(){
	local stations = AIStationList(Station.STATION_AIRPORT);
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Valuate(Station.GetProperty, "air.station.manager.check_date", 0);
	stations.KeepBelowValue(AIDate.GetCurrentDate() - 10);
	if(stations.Count() <= 0) return this.Sleep(50);

	stations.Sort(AIList.SORT_BY_VALUE, true);

	local station_id = stations.Begin();
	Station.SetProperty(station_id, "air.station.manager.check_date", AIDate.GetCurrentDate());

	//AILog.Info("Checking: " + Station.GetName(station_id));


	return this.Sleep(20);
}