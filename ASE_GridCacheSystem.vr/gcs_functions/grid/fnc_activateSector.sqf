 params["_gridIndex"];

private _i = GRID_COORDINATES find _gridIndex;

if (_i == -1) exitWith {};

	private _tableUnits = TABLE_INIT_UNITS select _i;

if (!(isNil "_tableUnits")) then {
	_vehicleArray = _tableUnits select 0;
	_infanteryGroupsArray = _tableUnits select 1;
	[_vehicleArray] call GCS_fnc_grid_loadUnits_createVehicles;
	[_infanteryGroupsArray] call GCS_fnc_grid_loadUnits_createInfanteryGroups;

};
