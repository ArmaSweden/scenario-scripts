fnc_lock_doors =
{
  _markerName = _this select 0;
  _range = _this select 1;
  _pos = getMarkerPos _markerName;
  _houses = nearestTerrainObjects [_pos, ["house","building"], _range];

  {
    _Doors = getNumber (configfile >> "CfgVehicles" >> typeOf _x >> "numberOfDoors");
    
    for "_i" from 1 to _Doors do {
      _var = format ["bis_disabled_Door_%1", _i];
      _anim = format ["Door_%1_rot", _i];
      _x animate[_anim, 0];
      _x setVariable [_var, 1, true];
    }
  
  } forEach _houses
};