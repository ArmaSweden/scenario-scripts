/**
	Check if a non-terrain vehicle is offroad, in that case, damage the weels.
	Use this script to prevent a group from driving offroad with vehicles not made for it.
	
*/

if (!isServer) exitWith {};

[] spawn {	
	
	while { sleep 3; true } do { 
		
		// Get all groups that must drive land vehicles on roads
		_allAffectedGroups = allGroups select {_x getVariable ["ASE_VehicleOnRoad", false]};
		
		{
			_affectedGroup = _x;	
			// If all units in the group is dead, move to the next one
			if ({ alive _x } count units _affectedGroup < 1) exitWith {};			
			
			{								
				// Check if this unit is on foot
				_isOnFoot = isNull objectParent _x;				
				if (_isOnFoot) exitWith {};					
				
				// The unit is in a vehicle, but process the driver unit only
				if ((driver vehicle _x) != _x) exitWith {};
				
				// Is this a land vehicle? Never mind air, water vehicles etc.
				_isLandVehicle = vehicle _x isKindOf "LandVehicle";				
				if (!_isLandVehicle) exitWith {};
				
				// Is this vehicle currently on a road?
				_vehicleOnRoad = isOnRoad vehicle _x;
				if (_vehicleOnRoad) exitWith {};
				
				// Check if this vehicle prefer roads or not, offroad vehicles are allowed to be offroads (surprise)
				_vehicleClass = typeOf vehicle _x;
				_preferRoads = getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "preferRoads");				
				if (_preferRoads == 0) exitWith {};				
				
				// Check if speed is over 10 km/h, it's ok to be offroads if the speed is low
				if (speed vehicle _x <= 10) exitWith {}; 
				
				// If we reached this point, the vehicle is not on roads, and does prefer to be on roads, and the unit is driving faster than 10 km/h.
				// Make them suffer. Hit the tires!				
				_randomWheel = selectRandom ["wheel_1_1_steering", "wheel_1_2_steering", "wheel_2_1_steering", "wheel_2_2_steering"];
				_currentDamage = (vehicle _x) getHit _randomWheel;				
				(vehicle _x) setHit [_randomWheel, _currentDamage + 0.25];
				
				// Or should we limit the max speed instead to something very very slow?
				_maxSpeed = getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "maxSpeed");				
				
				//systemChat format ["%1 hit: %2, max speed: %3", _randomWheel, _currentDamage, _maxSpeed];
				_msg = format ["Unit '%1' drove a vehicle offroad at grid %2", _x, mapGridPosition _x];
				systemChat _msg;					
				
			} forEach units _affectedGroup;
			
		} forEach _allAffectedGroups;
		
	};
	
};