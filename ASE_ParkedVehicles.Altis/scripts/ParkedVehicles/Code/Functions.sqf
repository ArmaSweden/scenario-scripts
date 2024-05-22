/*
 * Summary: Gets a parameter value in a paired list on format ["KEY", value].
 * Arguments:
 *   _params: List of paired value parameters.
 *   _key: String with key to look for.
 *   _default: Value that is returned if key was not found.
 * Returns: Value associated with key. ObjNull if no key was found.
 */
PARKEDVEHICLES_GetParamValue = {
  	private ["_params", "_key"];
  	private ["_value"];

   	_params = _this select 0;
   	_key = _this select 1;
	_value = if (count _this > 2) then { _this select 2 } else { objNull };

   	{
   		if (_x select 0 == _key) then {
   			_value = _x select 1;
   		};
   	} foreach (_params);
    	
   	_value
};

// Gets a building definition.
// _buildingClassName (String): The class name of the building.
// Returns (Array): The building definition. Empty array if building does not exist.
PARKEDVEHICLES_GetBuildingDefinition = {
	params ["_buildingClassName"];
	
	scopeName "main";
	
	{
		if ((_x select 0) == _buildingClassName) then {
			_x breakOut "main";
		};
	} foreach PARKEDVEHICLES_GarageDefinitions;
	
	[];
};

// Gets the distance from a vehicle to nearest player.
// _vehicle (Object): The vehicle to test.
// Returns (Scalar): The distance to nearest player in meters.
PARKEDVEHICLES_GetClosestDistanceToPlayer = {
	params ["_pos"];
	private _allPlayers = (call BIS_fnc_listPlayers) - (entities "HeadlessClient_F");
	
	private _closestDistance = 9999999;
	
	{
		if (_x distance2D _pos < _closestDistance) then {
			_closestDistance = _x distance2D _pos;
		};
	} foreach _allPlayers;
	
	_closestDistance
};

// Spawns all vehicles matching the provided parameter set.
PARKEDVEHICLES_PlaceVehiclesOnMap = {
	_this spawn {
		private _buildingClasses = [_this, "BUILDING_TYPES", ["Land_FuelStation_02_workshop_F"]] call PARKEDVEHICLES_GetParamValue;
		private _vehicleClasses = [_this, "VEHICLE_CLASSES", ["C_Offroad_01_F", "C_Offroad_01_repair_F", "C_Quadbike_01_F", "C_Hatchback_01_F", "C_Hatchback_01_sport_F", "C_SUV_01_F", "C_Van_01_transport_F", "C_Van_01_box_F", "C_Van_01_fuel_F"]] call PARKEDVEHICLES_GetParamValue;
		private _spawnRadius = [_this, "SPAWN_RADIUS", 750] call PARKEDVEHICLES_GetParamValue;
		private _probabilityOfPresence = [_this, "PROBABILITY_OF_PRESENCE", 1] call PARKEDVEHICLES_GetParamValue;
		private _onVehicleCreated = [_this, "ON_VEHICLE_CREATED", {}] call PARKEDVEHICLES_GetParamValue;
		private _onVehicleRemoving = [_this, "ON_VEHICLE_REMOVING", {}] call PARKEDVEHICLES_GetParamValue;
		private _debug = [_this, "DEBUG", false] call PARKEDVEHICLES_GetParamValue;
		
		sleep 1;
		
		private _allVehicles = [];
		private _allDebugMarkers = [];
		
		while { true } do
		{
			/* Remove all vehicle that are too far away */
			
			private _vehiclesToKeep = [];
			
			{
				private _vehicle = _x select 0;
				private _spawnPos = _x select 1;

				if (_vehicle distance _spawnPos > 3) then
				{
					// If vehicle is used in any way, do not touch it anymore, and do not spawn more vehicles at that garage
					private _building = _vehicle getVariable "ParkedVehicles_Building";
					_building setVariable ["ParkedVehicles_UseThisGarage", false];
				}
				else
				{
					private _distanceToNearestPlayer = [getPos _vehicle] call PARKEDVEHICLES_GetClosestDistanceToPlayer;
					
					if (_distanceToNearestPlayer > _spawnRadius) then {
						private _building = _vehicle getVariable "ParkedVehicles_Building";
						
						_building setVariable ["ParkedVehicles_SpawnedVehicle", objNull];
						[_vehicle, _building] call _onVehicleRemoving;
						deleteVehicle _vehicle;
					}
					else {
						_vehiclesToKeep pushBack _x;
					};
				};
			} foreach _allVehicles;
			
			_allVehicles = _vehiclesToKeep;

			/* Remove all debug markers that are too far away */
			
			if (_debug) then
			{
				private _debugMarkersToKeep = [];
				
				{
					private _distanceToNearestPlayer = [getMarkerPos _x] call PARKEDVEHICLES_GetClosestDistanceToPlayer;
					
					if (_distanceToNearestPlayer > _spawnRadius) then {
						deleteMarker _x;
					}
					else {
						_debugMarkersToKeep pushBack _x;
					};
				} foreach _allDebugMarkers;
			
				_allDebugMarkers = _debugMarkersToKeep;
			};
			
			/* foreach _buildingClasses */
			{
				private _buildingClass = _x;
				private _buildingDefinition = [_x] call PARKEDVEHICLES_GetBuildingDefinition;
				
				if (count _buildingDefinition > 0) then
				{
					private _buildingPosIndex = _buildingDefinition select 1;
					private _offsetPosition = _buildingDefinition select 2;
					private _vehicleDir = _buildingDefinition select 3;
					private _allPlayers = (call BIS_fnc_listPlayers) - (entities "HeadlessClient_F");
					private _buildings = [];
					
					private _firstPlayer = objNull;
					
					/* Find all buildings near players */
					
					/* foreach _allPlayers */
					{
						if (isNull _firstPlayer || { _x distance2D _firstPlayer > 100 }) then
						{
							private _playerBuildings = nearestObjects [_x, [_buildingClass], _spawnRadius + 0];
		
							if (isNull _firstPlayer) then
							{
								_firstPlayer = _x;
								_buildings = _playerBuildings;
							}
							else {
								{
									if (!(_x in _buildings)) then {
										_buildings pushBack _x;
									};
								} foreach _playerBuildings;
							};
						};
					} foreach _allPlayers;
					
					/* foreach _buildings */
					{
						private _building = _x;
						private _buildingHasVariables = _building getVariable ["ParkedVehicles_HasVariables", false];
						private _firstSpawnInThisBuilding = false;
						
						if (!_buildingHasVariables) then
						{
							private _useThisGarage = random 1 < _probabilityOfPresence;
							
							_firstSpawnInThisBuilding = true;
							_building setVariable ["ParkedVehicles_UseThisGarage", _useThisGarage];
							
							if (_useThisGarage) then {
								_building setVariable ["ParkedVehicles_ParkedVehicleClass", selectRandom _vehicleClasses];
								_building setVariable ["ParkedVehicles_SpawnedVehicle", objNull];
							};
							
							_building setVariable ["ParkedVehicles_HasVariables", true];
						};
						
						private _useThisGarage = _building getVariable "ParkedVehicles_UseThisGarage";
						private _spawnedVehicle = _building getVariable ["ParkedVehicles_SpawnedVehicle", objNull];
						
						if (_useThisGarage && isNull _spawnedVehicle) then
						{
							private _vehicleClass = _building getVariable "ParkedVehicles_ParkedVehicleClass";
							private _buildingPositions = [_building] call BIS_fnc_buildingPositions;
							
							if (count _buildingPositions > 0 || _buildingPosIndex == -1) then
							{
								private _buildingPos = getPos _building;
								
								if (_buildingPosIndex >= 0) then {
									_buildingPos = _buildingPositions select _buildingPosIndex;
								};
								
								private _buildingDir = getDir _building;
								
								private _spawnPos = _buildingPos getPos [_offsetPosition select 1, _buildingDir]; // y
								_spawnPos = _spawnPos getPos [_offsetPosition select 0, _buildingDir + 90]; // x
								_spawnPos = [_spawnPos select 0, _spawnPos select 1, _offsetPosition select 2]; // z
								
								private _objectsTooClose = false;
								private _nearObjects = (_spawnPos nearObjects 3) + ([_spawnPos select 0, _spawnPos select 1, 3] nearObjects 3) + (nearestTerrainObjects [_spawnPos, [], 3]) + (nearestTerrainObjects [[_spawnPos select 0, _spawnPos select 1, 3], [], 3]);
								
								{
									private _box = boundingBox _x;
									private _corner1 = _box select 0;
									private _corner2 = _box select 1;
									private _size = _corner1 distance2D _corner2;
									
									if (_size > 0.5 && _x != _building) then {
										//player sideChat str _size;
										_objectsTooClose = true; 
									};
								} foreach _nearObjects;
								
								if (!_objectsTooClose) then {
									private _vehicle = createVehicle [_vehicleClass, [_spawnPos select 0, _spawnPos select 1, 1000], [], 0, "CAN_COLLIDE"];
									
									_vehicle setDir (_buildingDir + _vehicleDir);
									_vehicle setPos _spawnPos;
									
									// Set textures
									private _textures = _building getVariable ["ParkedVehicles_VehicleTextures", getObjectTextures _vehicle];
									
									for "_i" from 0 to count _textures - 1 do {
										_vehicle setObjectTextureGlobal [_i, _textures select _i];
									};
									
									// Monitor vehicle health
									[_vehicle, _buildingClass, _vehicleClass, _spawnPos, _onVehicleCreated, _allVehicles, _building, _firstSpawnInThisBuilding, _allDebugMarkers, _debug] spawn {
										params ["_vehicle", "_buildingClass", "_vehicleClass", "_spawnPos", "_onVehicleCreated", "_allVehicles", "_building", "_firstSpawnInThisBuilding", "_allDebugMarkers", "_debug"];
										
										sleep 1;
										
										// If vehicle not exploded or flew away upon spawn
										if (alive _vehicle && _vehicle distance _spawnPos < 3) then {
											[_vehicle, _firstSpawnInThisBuilding, _building] call _onVehicleCreated;
											
											if (!isNull _vehicle) then {
												_allVehicles pushBack [_vehicle, _spawnPos];
												_building setVariable ["ParkedVehicles_SpawnedVehicle", _vehicle];
												_building setVariable ["ParkedVehicles_VehicleTextures", getObjectTextures _vehicle];
												_vehicle setVariable ["ParkedVehicles_Building", _building];
									
												if (_debug) then
												{
													private _debugMarker = createMarker [format ["parked_vehicles_marker%1", PARKEDVEHICLES_UniqueMarkerNo], _spawnPos];
													PARKEDVEHICLES_UniqueMarkerNo = PARKEDVEHICLES_UniqueMarkerNo + 1;
													_allDebugMarkers pushBack _debugMarker;
													
													_debugMarker setMarkerShape "ICON";
													_debugMarker setMarkerType "mil_dot";
													_debugMarker setMarkerColor "ColorWhite";
												};
											};
										}
										else {
											private _msg = "Engima.ParkedVehicles: Vehicle class " + _vehicleClass + " destroyed when put in building class " + _buildingClass + " on " + worldName + " at " + (str _spawnPos) + ".";
											diag_log _msg;
											
											// Do not use this garage any more
											_building setVariable ["ParkedVehicles_UseThisGarage", false];
											
											if (_debug) then {
												player sideChat _msg;
												
												private _marker = createMarker ["ParkedVehiclesFailMarker" + str PARKEDVEHICLES_UniqueMarkerNo, _spawnPos];
												PARKEDVEHICLES_UniqueMarkerNo = PARKEDVEHICLES_UniqueMarkerNo + 1;
												_allDebugMarkers pushBack _marker;
											
												_marker setMarkerType "mil_dot";
												_marker setMarkerColor "ColorBlack";
												_marker setMarkerText "Destroyed";
											};
											
											deleteVehicle _vehicle;
										};
									};
								}
								else {
									if (_debug) then {
										player sideChat _buildingClass + ": Object too close! Vehicle not spawned.";
										
										private _debugMarker = createMarker [format ["parked_vehicles_marker%1", PARKEDVEHICLES_UniqueMarkerNo], _spawnPos];
										PARKEDVEHICLES_UniqueMarkerNo = PARKEDVEHICLES_UniqueMarkerNo + 1;
										_allDebugMarkers pushBack _debugMarker;
										
										_debugMarker setMarkerShape "ICON";
										_debugMarker setMarkerType "mil_dot";
										_debugMarker setMarkerColor "ColorRed";
										_debugMarker setMarkerText "Too Close";
									};
								};
							};
						};
					} foreach _buildings;
				}
				else {
					if (_debug) then {
						player sideChat "Building class '" + _buildingClass + "' is not represented as a garage definition.";
					};
					
					private _msg = "Building class '" + _buildingClass + "' is not represented as a garage definition.";
					diag_log _msg;
				};
			} foreach _buildingClasses;
			
			if (_debug) then {
				player sideChat "Engima's Parked Vehicles: " + (str (count _allVehicles)) + " vehicles currently in or near garages/buildings."
			};
			
			sleep 5;
		};
	};
};

/* Functions that may be of help when creating more building definitions. */

PARKEDVEHICLES_InvestigateClosestBuilding = {
	private _building = nearestBuilding player;
	player sideChat (typeOf (_building));
	
	private _positions = [_building] call BIS_fnc_buildingPositions;
	player sideChat (str count _positions) + " positions.";
	
	{
		createVehicle ["Sign_Arrow_Blue_F", _x, [], 0, "CAN_COLLIDE"];
	} foreach _positions;
};

// Monitors the garage definition for a building and writes the values on screen and in the Arma RTF.
// _building (Object): The building for which to find the garage definition.
// _vehicle (Object): The vehicle used when finding the garage definition.
PARKEDVEHICLES_MonitorGarageDefinition = {
	params ["_building", "_vehicle"];
	private ["_definition", "_fullDefinition", "_strOldDefinition", "_buildingType", "_buildingPos", "_buildingOffsetPos", "_vehicleDir", "_buildingDir"];
	
	_buildingType = typeOf _building;
	_buildingPos = -1;
	_strOldDefinition = "";
	_buildingDir = getDir _building;
	
	while { true } do
	{
		_buildingOffsetPos = [0, 0, 0] getPos [(getPos _building) distance2D (getPos _vehicle), (getPos _building) getDir (getPos _vehicle)];
		
		for "_i" from 0 to 1 do {
			private _x = _buildingOffsetPos select _i;
			
			if (abs _x < 0.1) then {
				_x = 0;
			};
			
			_buildingOffsetPos set [_i, round (_x * 100) / 100];
		};
		
		_buildingOffsetPos set [2, 0.01];
		
		_vehicleDir = round ((getDir _vehicle) - _buildingDir);
		
		if (_vehicleDir >= 360) then {
			_vehicleDir = _vehicleDir - 360;
		};
		if (_vehicleDir < 0) then {
			_vehicleDir = _vehicleDir + 360;
		};
		
		_definition = [_buildingOffsetPos, _vehicleDir];
		_fullDefinition = [_buildingType, _buildingPos, _buildingOffsetPos, _vehicleDir];
		
		if (str _definition != _strOldDefinition) then {
			hint str _definition;
			diag_log ("PARKEDVEHICLES: Definition: " + str _fullDefinition);
			_strOldDefinition = str _definition;
		};
		
		sleep 0.1;
	};
};
