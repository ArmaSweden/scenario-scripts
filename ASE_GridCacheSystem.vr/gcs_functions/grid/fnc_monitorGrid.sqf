params["_GCS_VAR_SIZE_SQUARE_GRID", "_GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID", "_GCS_VAR_SIZE_UNSPAWN_SQUARES"];
GCS_VAR_ACTIVATED_GRID = [];
_debugMarkers = [];
while {true} do
{
	// ToDo (optimization): do not check all players. Check first id some are grouped and near each other
	private _playerList = [] call GCS_fnc_tools_getPlayerList;
	private _touchedUnSpawnSquares = [];
	{
		private _player = _x;
		// find activated cells
		private _activatedSquares = [getPos _player, _GCS_VAR_SIZE_SQUARE_GRID, _GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID] call GCS_fnc_grid_getActivatedSquares;

		// store cells if not already and activate area
		{
			if (not (_x in GCS_VAR_ACTIVATED_GRID)) then
			{
				GCS_VAR_ACTIVATED_GRID pushBack _x;
				// activate spawn in grid
				[_x] call GCS_fnc_grid_activateSector;


			};

		} forEach _activatedSquares;

		// find all the unspawn grid squares where players are inside
		private _insideUnSpawnSquares = [getPos _x, _GCS_VAR_SIZE_SQUARE_GRID, _GCS_VAR_SIZE_UNSPAWN_SQUARES] call GCS_fnc_grid_getActivatedSquares;
		{
			if (not (_x in _touchedUnSpawnSquares )) then
			{
				_touchedUnSpawnSquares pushBack _x;
			};
		} forEach _insideUnSpawnSquares;

	} forEach _playerList;

	// find if activated grid area are not in the touched, larger,  unspawn area (should be deactivated if so)
	_deleted = [];
	{
		if (not (_x in _touchedUnSpawnSquares)) then
		{
			GCS_VAR_ACTIVATED_GRID = GCS_VAR_ACTIVATED_GRID - [_x];
			_deleted pushBack _x;
			// delete stuff in grid
			[_x] call GCS_fnc_grid_deactivateSector;
		};

	} forEach GCS_VAR_ACTIVATED_GRID;

	// debug markers
	if (GCS_VAR_GRIDSYSTEM_DEBUG_MARKERS) then
	{
		{
			_nameMarker = format ["%1_%2_%3", 'grid', _x select 0, _x select 1];
			if (not (_nameMarker in _debugMarkers)) then
			{
				[[_x select 0, _x select 1],'grid', _GCS_VAR_SIZE_SQUARE_GRID, 'ColorWhite', _GCS_VAR_SIZE_SQUARE_GRID] call GCS_fnc_grid_createGridMarker;
				_debugMarkers pushBack _nameMarker;
			};

		} forEach GCS_VAR_ACTIVATED_GRID;

		{
			_nameMarker0 = format ["%1_%2_%3", 'grid', _x select 0, _x select 1];
			_debugMarkers = _debugMarkers - [_nameMarker0];
			deleteMarker _nameMarker0;
		} forEach _deleted;
	};


	sleep GCS_VAR_MONITORING_FREQUENCY_SECS;
};