// Functions compilation
_handle = execVM "gcs_functions\GCS_configServer.sqf";
waitUntil { scriptDone _handle };
call compile preprocessFileLineNumbers "gcs_functions\gcs_compile_server.sqf";

// Grid indices
_N = ceil(worldSize / GCS_VAR_SIZE_SQUARE_GRID);
GRID_COORDINATES = [];
for "_ix" from 0 to (_N - 1) step 1 do
{
	for "_iy" from 0 to (_N - 1) step 1 do
	{
		GRID_COORDINATES pushBack [_ix, _iy];
	};
};


// Cache all units
	TABLE_INIT_DONE = false;
	TABLE_INIT_UNITS = [];
	TABLE_INIT_UNITS = call GCS_fnc_grid_cacheAll;
	waitUntil{ sleep 2; TABLE_INIT_DONE };

// Waits for the initial caching to be done, then starts the grid monitoring
[GCS_VAR_SIZE_SQUARE_GRID,GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID, GCS_VAR_SIZE_UNSPAWN_SQUARES] spawn GCS_fnc_grid_monitorGrid;