 params["_group", "_waypointsInfo"];
{
	_waypoint = _group addWaypoint [_x select 2, _x select 3/*, _x select 0, _x select 4*/];
	_waypoint setWaypointType (_x select 1);
	_waypoint setWaypointBehaviour (_x select 5);
	_waypoint setWaypointFormation (_x select 6);
	_waypoint setWaypointStatements (_x select 7);
	_waypoint setWaypointTimeout (_x select 8);
	_waypoint setWaypointScript (_x select 9);
} forEach  _waypointsInfo;


