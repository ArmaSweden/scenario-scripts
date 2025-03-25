private['_vehicles'];
_vehicles = [];
 {
 	if ((_x isKindOf "Air") or(_x isKindOf "LandVehicle") or (_x isKindOf "Ship")) then
 	{
 		_vehicles pushBack _x;
 	};
 } forEach vehicles;
 _vehicles