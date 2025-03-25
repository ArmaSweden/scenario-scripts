params["_veh", "_index"];

private _nameVehicle = format ["%1_%2", typeof _veh, _index];
private _className = typeof _veh;
private _damage = getDammage _veh;
private _position = getPosATL _veh;
private _direction = getDir _veh;
private _basicInfo = [_nameVehicle, _className, _damage, _position, _direction];
private _saveVehicle = [_veh] call GCS_fnc_grid_saveUnits_modifiedSaveVehicle;
private _saveCargo =  [_veh] call GCS_fnc_grid_saveUnits_getVehicleContent;

if (not isNull (driver _veh)) then
{
	_waypointsDriver = [group driver _veh] call GCS_fnc_grid_saveUnits_saveWaypoints;
	[_basicInfo, _saveVehicle, _saveCargo, _waypointsDriver]
}
else
{
	[_basicInfo, _saveVehicle, _saveCargo]
};
