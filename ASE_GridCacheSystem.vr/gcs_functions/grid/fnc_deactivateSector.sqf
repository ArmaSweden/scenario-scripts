params["_gridIndex", "_disableSaving", "_disableRemove"];
private _GCS_VAR_SIZE_SQUARE_GRID = GCS_VAR_SIZE_SQUARE_GRID;

private _i = GRID_COORDINATES find _gridIndex;
if (_i == -1) exitWith {};

_start = diag_tickTime;
private _center = [_gridIndex, _GCS_VAR_SIZE_SQUARE_GRID] call GCS_fnc_grid_gridToPos;
private _tableUnits = [];
_unitsCount = 0;

// Remove vehicles, crew and cargo
_vehiclesArray = [];
_cargoArray = [];
{
	// delete and save vehicles only if variable "UseGrid" is defined
	if (! isNil { _x getVariable "UseGrid" }) then
	 {
	 	if (_x getVariable "UseGrid" ) then
	 	{
	 		_pos = getpos _x;
			private _isInside = _pos inArea [_center, _GCS_VAR_SIZE_SQUARE_GRID/2, _GCS_VAR_SIZE_SQUARE_GRID/2, 0, true];
			if (_isInside) then
			{
				_save = [_x, 0] call GCS_fnc_grid_saveUnits_getVehicleInfo;
				if (damage _x < 1) then
				{
					_vehiclesArray pushBack _save;
				};

				if (isNil "_disableRemove") then {
					{deleteVehicle _x;}forEach crew _x;
					deleteVehicle _x;
				};
			};
		};
	 };
} forEach ([] call GCS_fnc_tools_getAllVehicles);

_tableUnits pushBack _vehiclesArray;

// Gets the player list so that we do not store any player (or playable) units
_playableList = [] call GCS_fnc_tools_getPlayerList;

_infanteryGroupsArray = [];
{
	if (! isNil { (leader _x) getVariable "UseGrid" }) then
	 {
	 	if ((leader _x) getVariable "UseGrid" ) then
	 	{
			if (! (leader _x in _playableList)) then
			{
				_isInside = (leader _x) inArea [_center, _GCS_VAR_SIZE_SQUARE_GRID/2, _GCS_VAR_SIZE_SQUARE_GRID/2, 0, true];
				if (_isInside) then {
				
					private _leaderUnit = leader _x;
					_group = _x;
					_groupIndex = _foreachIndex;
					{
						private _groupName = format ["group_%1", _groupIndex];
						_array = [_x, _group, _groupName, _leaderUnit] call GCS_fnc_grid_saveUnits_getUnitInfo;
						
						if (! ((damage _x) isEqualTo 1)) then {
							_infanteryGroupsArray pushBack _array;
							_unitsCount = _unitsCount + 1;
						};
						if (isNil "_disableRemove") then {
							deleteVehicle _x;
						};
					} forEach (units _x);
					if (isNil "_disableRemove") then {
						deleteGroup _group;
					};
				};
			};
		};
	};
} forEach allGroups;

_tableUnits pushBack _infanteryGroupsArray;

	// Updates the TABLE_INIT_UNITS local variable
	if (TABLE_INIT_DONE) then { TABLE_INIT_UNITS set [_i, _tableUnits];	};

_end = diag_tickTime;
if (_unitsCount > 0) then { ["Grid %1 unloaded with %2 units in %3 seconds", _gridIndex, _unitsCount, (_end - _start)] call BIS_fnc_logFormat; }; //DEBUG
_tableUnits