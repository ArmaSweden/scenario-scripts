/**
  Groups (intended for AI) with variable ASE_ReportEnemy set to true, will report over side radio if they encounter i.e. "knowsAbout" an enemy unit.
  Enemy have to be in "line-of-sight" to be reported.
  
  Usage: 
  
  Put the following line in the init section of a unit:
  
  (group this) setVariable ["ASE_ReportEnemy", true] 
  
  @author Beck [ASE] - Discord Beck#1679
*/

if (!isServer) exitWith {};

// Once an enemy is detected, the reporting group will wait for the given time before reporting in
// i.e. give the enemy a chance to take this group out
ASE_Report_Enemy_Timeout = 15; // in seconds before reporting
ASE_Report_Pos_Interval = [240, 300, 360]; // how often a patroling unit report their own position [min, mid, max]
ASE_Report_Enemy_Interval = 120; // if enemy is reported, wait this long before we report again

[] spawn {	

	while { sleep 5; true } do { 
		
		_allGroupsOnPatrol = allGroups select {_x getVariable ["ASE_ReportEnemy", false]};
		_allEnemyGroups = allGroups select {side _x == east};

		{
			_patrolGroup = _x;	
			_patrolDead = false;
			
			// If the all units in the patrol group is dead or unconscious, we can't report in
			if ({ alive _x } count units _patrolGroup < 1) exitWith {
				_patrolDead = true;
			};
						
			// Report position of this patroling group			
			_reportPositionTimer = _patrolGroup getVariable ["ASE_ReportPosTimer", 0];
			if (!_patrolDead && time > _reportPositionTimer) then {
				
				// Draw/update own marker on map								
				[_patrolGroup, (getPos leader _patrolGroup), "b_unknown"] call ASE_fnc_UpdateMarker;
				// Report in on sideChat
				[leader _patrolGroup, "Reporting position (marked on map)"] remoteExec ["sideChat"];
				// Update interval
				_patrolGroup setVariable ["ASE_ReportPosTimer", time + (random ASE_Report_Pos_Interval)];
			};						
			
			{				
				_enemyGroup = _x;
				
				// See if anyone in patrol group knowns about any unit in this enemy group
				{					
					_enemyUnit = _x;
					
					if (!_patrolDead && _patrolGroup knowsAbout _enemyUnit >= 1.5) then {											
							
						_enemyLocation = getPos _enemyUnit;
												
						// Check if any unit in the patrol group can see the current enemy unit
						_canSee = 0;
						{
							_patrolUnit = _x;							
							_canSee = [objNull, "VIEW"] checkVisibility [eyePos _patrolUnit, eyePos _enemyUnit];
						} forEach (units _patrolGroup);
						
						systemChat format ["Enemy: %1, KA: %2, CS: %3", groupId _enemyGroup, _patrolGroup knowsAbout _x, _canSee];
						
						// Can't see any of the enemy units, so we can't update position
						if (_canSee < 1) exitWith {systemChat "Can't see the enemy";};
						
						// Exit if this enemy has been reported recently
						_reportTimer = _enemyGroup getVariable ["ASE_ReportEnemyTimer", 0];						
						if (time < _reportTimer) exitWith {systemChat "Enemy recently spotted, no need to update";};																																		
						// Give any previous spawn thread a chance to start before creating a new one on the same observation
						_enemyGroup setVariable ["ASE_ReportEnemyTimer", time + ASE_Report_Enemy_Timeout + 5];																								
						
						// Use exitWith, it is enough that one unit in the patrol group report about the enemy
						if (true) exitWith {
							// Spawn new report thread
							[_patrolGroup, _enemyGroup, _enemyLocation] spawn {
								params ["_patrolGroup", "_enemyGroup", "_enemyLocation"];																							
								
								// Give the enemy a change to take this group out before we report in
								sleep ASE_Report_Enemy_Timeout;																																																													
								
								// If the all units in the patrol group is dead or unconscious, we can't report in
								if ({ alive _x } count units _patrolGroup < 1) exitWith {
									// Reset report timers to allow another group to report this enemy unit
									_enemyGroup setVariable ["ASE_ReportEnemyTimer", 0];
								};
								
								// Draw/update enemy marker on map
								[_enemyGroup, _enemyLocation, "o_unknown"] call ASE_fnc_UpdateMarker;																
								// Draw/update own marker on map								
								[_patrolGroup, (getPos leader _patrolGroup), "b_unknown"] call ASE_fnc_UpdateMarker;								
								
								// Store this timer on the enemy group
								_enemyGroup setVariable ["ASE_ReportEnemyTimer", time + ASE_Report_Enemy_Interval];								
								
								// Report in on sideChat
								_msg = format ["Enemy %1 spotted! At grid %2 (marked on map)", groupId _enemyGroup, mapGridPosition _enemyLocation];								
								[leader _patrolGroup, _msg] remoteExec ["sideChat"];
								//systemChat _msg;
								
							}; // end spawn
						}; // end if exitwith
					}; // end if
					
				} forEach (units _enemyGroup);
				
			} forEach _allEnemyGroups;
			
		} forEach _allGroupsOnPatrol;
		
	};	
	
};

ASE_fnc_UpdateMarker = {
	params ["_group", "_location", "_markerType"];
	
	// First delete old marker, if any
	_oldMarker = _group getVariable ["ASE_GroupMarker", ""];
	deleteMarker _oldMarker;
								
	_now = date; // [2014,10,30,2,30] (Oct. 30th, 2:30am)
	_hour = _now select 3;
	_min  = _now select 4;
	_hhmm = format ["%1:%2", _hour, _min];
	
	// Draw/update own marker on map								
	_markerName = format ["BFM-%1", groupId _group];
	_markerName = createMarker [_markerName, _location];								
	_markerName setMarkerType _markerType;
	_markerName setMarkerText format ["%1 (%2)", groupId _group, _hhmm];		
	
	// Store marker
	_group setVariable ["ASE_GroupMarker", _markerName];	
};

