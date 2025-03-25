params["_infanteryGroupsArray"];

private _groups = [];
private _groupsNames = [];
private _leaders = [];

{
	private _nameUnit = _x select 0;
	private _className = _x select 1;
	private _side = _x select 2;
	private _damage = _x select 3;
	private _position = _x select 4;
	private _direction = _x select 5;
	private _unitPos = _x select 6;
	private _group = _x select 7;
	private _groupName = _x select 8;
	private _leader = _X select 9;
	private _isleader = _x select 10;
	private _rank = _x select 11;
	private _skill = _x select 12;
	private _behaviour = _x select 13;
	private _speed = _x select 14;

	if (_isleader) then
	{
	
		private _group0 = createGroup _side;
		_groups pushBack _group0;
		_groupsNames pushBack _groupName;
		_leaders pushBack _leader;
				
		_waypointsInfo = _x select 15;

		_unit = [_nameUnit, _className, _side, _damage, _position, _direction, _unitPos, _group0, _rank, _skill, _behaviour, _speed] call GCS_fnc_grid_loadUnits_createUnit;
		_unit setVariable ["UseGrid", True];
		_leaders pushBack _unit;
		if (count _waypointsInfo > 1) then
		{
			[_group0, _waypointsInfo] call GCS_fnc_grid_loadUnits_setWaypoints;
		};
	}
	else{
		_index = _groupsNames find _groupName;
		if (_index != -1) then
		{
			_unit = [_nameUnit, _className, _side, _damage, _position, _direction, _unitPos, _groups select _index, _rank, _skill, _behaviour, _speed] call GCS_fnc_grid_loadUnits_createUnit;
			_unit setVariable ["UseGrid", True];
		};
	};

} forEach _infanteryGroupsArray;
systemChat format ["%1", _infanteryGroupsArray];