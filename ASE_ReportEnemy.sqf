/**
  Groups (intended for AI) with variable ASE_ReportEnemy set to true, will report over side radio if they encounter i.e. "knowsAbout" an enemy unit.
  Enemy have to be in "line-of-sight" to be reported.
  
  Usage: 
  
  Put the following line in the init section of a unit:
  
  (group this) setVariable ["ASE_ReportEnemy", true] 
  
  @author: Beck 
*/

if (!isServer) exitWith {};

// Once an enemy is detected, the reporting group will wait for the given time before reporting in
// i.e. give the enemy a chance to take this group out
ASE_ReportEnemy_Timeout = 5; // in seconds before reporting
ASE_ReportEnemyInterval = 120; // if reported, wait a while until we report again

[] spawn {	

	while { sleep 5; true } do { 
		
		_allGroupsOnPatrol = allGroups select {_x getVariable ["ASE_ReportEnemy", false]};
		_allEnemyGroups = allGroups select {side _x == east};

		{
			_patrolGroup = _x;	
			
			{
				
				_enemyGroup = _x;
				
				// See if anyone in patrol group knowns about any unit in this enemy group
				{					
									
					if (_patrolGroup knowsAbout _x >= 1.5) then {
					
						// If the all units in the patrol group is dead or unconscious, we can't report in
						if ({ alive _x } count units _patrolGroup < 1) exitWith {systemChat "This group is dead";};
							
						_enemyLocation = getPos _x;
						_grid = mapGridPosition _enemyLocation;												
												
						// Check if any unit in the patrol group can see any enemy unit						
						_enemyUnit = _x;
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
						if (time < _reportTimer) exitWith {systemChat "Recently spotted, no need to update";};																																		
						// Give any previous spawn thread a chance to start before creating a new one on the same observation
						_enemyGroup setVariable ["ASE_ReportEnemyTimer", time + ASE_ReportEnemy_Timeout + 5];																								
						
						// Use exitWith, it is enough that one unit in the patrol group report about the enemy
						if (true) exitWith {
							// Spawn new report thread
							[_patrolGroup, _enemyGroup, _enemyLocation] spawn {
								params ["_patrolGroup", "_enemyGroup", "_enemyLocation"];
															
								//systemChat format ["Spawning: %1, %2, %3", _patrolGroup, _enemyGroup, _enemyLocation];
								
								// Give the enemy a change to take this group out before we report in
								sleep ASE_ReportEnemy_Timeout;
								
								// If the all units in the patrol group is dead or unconscious, we can't report in
								if ({ alive _x } count units _patrolGroup < 1) exitWith {};													
								
								_msg = format ["Enemy '%1' spotted at grid %2 (marked on map)", groupId _enemyGroup, mapGridPosition _enemyLocation];
								//systemChat _msg;
								
								// First delete old marker, if any
								_oldMarker = _enemyGroup getVariable ["ASE_ReportEnemyMarker", ""];
								deleteMarker _oldMarker;
								
								// Draw/update enemy marker on map
								_markerName = createMarker [format ["%1:%2", groupId _enemyGroup, mapGridPosition _enemyLocation], _enemyLocation];
								_markerName setMarkerType "o_unknown";
								_now = date; // [2014,10,30,2,30] (Oct. 30th, 2:30am)
								_hour = _now select 3;
								_min  = _now select 4;
								_markerName setMarkerText format ["%1 (%2)", groupId _enemyGroup, format ["%1:%2", _hour, _min]];
								
								// Draw/update own marker on map
								_bfMarkerName = createMarker [format ["%1:%2", groupId _patrolGroup], getPos leader _patrolGroup];
								_bfMarkerName setMarkerType "b_unknown";
								_bfMarkerName setMarkerText groupId _patrolGroup;
								
								_enemyGroup setVariable ["ASE_ReportEnemyMarker", _markerName];
								_enemyGroup setVariable ["ASE_ReportEnemyTimer", time + ASE_ReportEnemyInterval];
								
								systemChat format ["Added marker: %1", _markerName];
								
								// Report in on sideChat
								[leader _patrolGroup, _msg] remoteExec ["sideChat"];
								
							}; // end spawn
						}; // end if exitWith
					}; // end if
					
				} forEach (units _enemyGroup);
				
			} forEach _allEnemyGroups;
			
		} forEach _allGroupsOnPatrol;
		
	};	
	
};
