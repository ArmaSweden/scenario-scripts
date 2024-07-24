//_unit = _this select 0; //The subject
//params["_unit", ["_toggleHoldAction", true], ["_codeOnEnd", {}], ["_toggleOn", true]];	//get parameters from calling line. TODO Holdaction and toggle becomes true?
params ["_target", "_caller", "_actionId", "_arguments"]; //obj assigned, obj that activated function, Number - ID of the activated action (same as ID returned by addAction), Array - arguments given to the function

// _trackedUnit = player;	//Subject tracks player who is _trackedUnit
// _vehicle = ;				//
// _vehicleToggle= ;		//
_idHoldAction = _actionId; //ID number
_unit = _target; 		// the subject that follows the player
_toggle = true; 		// True = show follow action, False = show hold action
_toggleOn = true; 		// True = Escort is active, False = Escort is not active ??
_toggleHoldAction = true;// True = Follow action, False = Stop action


// LEAVING A VEHICLE CHECK. IF PLAYER OUTSIDE VEHICLE. MOVE SUBJECT OUT OF VEHICLE AND MAKE PLAYER THE FOLLOWED UNIT AGAIN.
BIS_fnc_escortAIVehicle = {										//Name of function
	params["_vehicle", ["_toggleOn", true]];					//Parameters from the calling line (vehicle, [toggleOn, true])
	player setVariable ["_vehicleToggle", _toggleOn];			//Give player the variable _vehicleToggle with value from _toggleOn
																//case when the player is outta vehicle
	if (vehicle player isEqualTo player && _toggleOn) then { 	//if player not in vehicle and _toggleOn is true then 
		_trackedUnit = player getVariable "_trackedUnit"; 		//Give _trackedUnit/player the current value from players variable _trackedUnit
		unassignVehicle _trackedUnit; 							//If the unit is currently in that vehicle, the group leader will issue an order to disembark.
		moveOut _trackedUnit;									//Moves the soldier out of the vehicle
		[_vehicle, false] spawn BIS_fnc_holdActionVehicle; 		//
	};
};


// HOLDACTION ESCORTAIVEHICLE. IF _toggleHoldAction IS FALSE DO VEHICLE CHECK, REMOVE ACTION FROM VEHICLE. IF TRUE SET HOLDACTION AND VALUES ON VEHICLE.
BIS_fnc_holdActionVehicle = {									//Name of function
	params["_vehicle", ["_toggleHoldAction", true], ["_codeOnEnd", {}], ["_toggleOn", true]]; //Parameters from a holdaction?
					// IF _toggleHoldAction IS FALSE. CALL BIS_fnc_escortAIVehicle AND REMOVE _idHoldAction
	if (!_toggleHoldAction) exitWith {							//if _toggleHoldAction is false exit function with these instructions
		[_vehicle, false] call BIS_fnc_escortAIVehicle;			//call BIS_fnc_escortAIVehicle with parameters [_vehicle, false]
		[_vehicle, _vehicle getVariable "_idHoldAction"] call BIS_fnc_holdActionRemove;//TODO remove holdaction _idHoldAction. [target,ID] call BIS_fnc_holdActionRemove
		_vehicle setVariable ["_idHoldAction", nil];			//set vehicles variable _idHoldAction = empty
		player setVariable ["_vehicleToggle", nil];				//set players value _vehicleToggle = empty
		true};													//exit function here
					// AND IS _toggleHoldAction TRUE. SWITCH _idHoldAction TO SET WHAT UNITS TO RUN HOLDACTION ON
	_idHoldAction = [_vehicle, "true", "true", BIS_fnc_escortAIVehicle, BIS_fnc_holdActionVehicle, _toggleOn, {}, false]; //Change values on _idHoldAction
	_vehicle setVariable ["_idHoldAction", _idHoldAction];		//give the vehicle the value _idHoldAction
	player setVariable ["_vehicleToggle", _toggleOn];			//give the player the value _vehicleToggle = true/false
};																//end of function


// END ESCORT, STOP SUBJECT
if (!_toggleOn) exitWith {										//if _toggleOn is false exit exit function with these instructions
	doStop _unit;												//Order _unit to stop
	player removeEventHandler ["GetInMan", player getVariable ["_idGetInMan", -1]];  //
	player removeEventHandler ["GetOutMan", player getVariable ["_idGetOutMan", -1]];//
	player setVariable ["_idGetInMan", nil];					//remove variable _idGetInMan
	player setVariable ["_idGetOutMan", nil];					//remove variable _idGetOutMan
	player setVariable ["_npcIsFollowing", nil];				//remove variable _npcIsFollowing
};


// REMOVES EVENTHANDLER/HOLDACTION FROM SUBJECT
//if (vehicleVarName _unit isEqualTo "") exitWith {}; 									//no variable name
if (!_toggleHoldAction) exitWith {														//if _toggleHoldAction is false exit with these lines
	[_unit, false] call BIS_fnc_escortAI;												//subject call BIS_fnc_escortAI with parameter false. Undocumented BIS function.
	[_unit, _unit getVariable "_idHoldAction"] call BIS_fnc_holdActionRemove;			//TODO Remove action from subject. [target,ID] call BIS_fnc_holdActionRemove
	// _unit setVariable ["_idHoldAction", nil];										//delete subject value for _idHoldAction
	// private _idDeletedHandler = _unit getVariable ["_idDeletedHandler", -1];			//set var _idDeletedHandler to subjects value for _idDeletedHandler
	// if (_idDeletedHandler > -1) then { _unit removeEventHandler ["Deleted", _idDeletedHandler]; };
	// _unit setVariable ["_idDeletedHandler", nil];									//delete subject value _idDeletedHandler
	true
};


// ADD HOLDACTION, VALUES AND EVENTHANDLER ON SUBJECT
_text1 = if (_toggle) then { "escort VIP"} else { "stop VIP" };
_text2 = if (_toggle) then { "images\holdAction_follow_start_ca.paa" } else { "images\holdAction_follow_stop_ca.paa" };

_idHoldAction = [_unit,
				_text1,
				_text2,
				_text2,
				"alive _unit && player distance _target < 5",
				"true",
				{},
				{},
				{ 	_arguments params["_toggleOn",["_codeOnEnd", {}]];
					[_target, _toggleOn] call BIS_fnc_escortAIVehicle; 
					[_target, true, {},!_toggleOn] call BIS_fnc_holdActionVehicle; 
					[] call _codeOnEnd; 
				},
				{},
				[],
				1,
				0
				] call BIS_fnc_holdActionAdd;

//_idHoldAction = [_unit, _condition, _condition, BIS_fnc_escortAIVehicle, BIS_fnc_holdActionVehicle, _toggleOn, _codeOnEnd, true]; //Feed values to a variable
_unit setVariable ["_idHoldAction", _idHoldAction];										//give subject values "_idHoldAction" = _idHoldAction from addholdaction above


// EVENTHANDLER WHEN SUBJECT GETS IN VEHICLE
	private _idDeletedHandler = _unit addEventHandler ["Deleted",{						//set eventhandler "Deleted" on subject
		params["_unit"];
		private _getInFired = _unit getVariable ["_getInFired", 0];						//when subject gets into vehicle
		if (_getInFired > 0 && (time-_getInFired) <= 5) exitWith {};					//exit script if it takes too long? TODO serverTime?
	
		_unit setVariable ["_getInFired", nil];											//remove value _getInFired from subject
		[_unit, false] call BIS_fnc_escortAIHoldAction;									//subject calls BIS_fnc_escortAIHoldAction

		[vehicleVarName _unit] spawn {													//returns variable name of subject
			params["_unitName"];														//parameter with subjects name
			sleep 2;
			private _unit = objNull;													//remove subject as the
			waitUntil {sleep 0.5; _unit = (missionNamespace getVariable [_unitName, objNull]); !isNull _target};
			[_unit] call BIS_fnc_escortAIHoldAction; // HOLDACTION ESCORTAIVEHICLE. IF _toggleHoldAction IS TRUE. REMOVE HOLDACTION FROM VEHICLE AND EMPTY THE VALUES. ELSE SET HOLDACTION ON VEHICLE.
		}
	}];
	
_unit setVariable ["_idDeletedHandler", _idDeletedHandler];								// Give subject value "_idDeletedHandler" for later deletion

// PREPARE SUBJECT TO FOLLOW player
{deleteWaypoint _x} forEach waypoints group _unit;
_unit setSpeedMode "LIMITED";						//Bunch of commands for the subject
_unit setSkill 1;								//skill 100
_unit setCombatMode "BLUE";
_unit setBehaviour "CARELESS";
_unit setUnloadInCombat [false, false];			//If true, vehicle will stop and units will dismount. Vehicle must be local.
_unit doFollow _unit; 							//resuming unit from stop
_unit enableSimulation TRUE;
_unit switchMove "";
player setVariable ["_npcIsFollowing", true];	//give player the value _npcIsFollowing = true


// MAKE SUBJECT FOLLOW PLAYER WHEN NOT IN VEHICLE AND _npcIsFollowing IS FALSE
[_unit] spawn {
	params["_unit"];
	while {(player getVariable ["_npcIsFollowing", false])} do {				//while player has value _npcIsFollowing = false do the following
		if (vehicle player isEqualTo player) 									//if player is not in a vehicle
		then {	if (player distance2D _unit >= 3) 								//then if subject is more than 5m away from player
				then { _unit doMove (getPos vehicle player); } 					//make subject go to player
				else {_unit lookAt player; doStop _unit;_unit doFollow _unit; };//Subject look at player and stop; 
		};
		sleep 0.5;
	};
};

player setVariable ["_trackedUnit", _unit]; //Sets player value _trackedUnit = subject


// GIVE player EVENTHANDLER FOR GETTING INTO VEHICLES WITH SUBJECT
if ((player getVariable ["_idGetInMan", -1]) isEqualTo -1) then {	//If player has variable _idGetInMan -1 then

	_idGetInMan = player addEventHandler ["GetInMan", {  			//Create a trigger every time player gets in vehicle and call it _idGetInMan
			params["_unit", "_positon", "_vehicle"]; 				//Parameters from calling line (subject, position and the vehicle)
			_trackedUnit = _unit getVariable "_trackedUnit";		//Change the subject into Var_trackedUnit and give same string as subject
			_trackedUnit setVariable ["_getInFired", time]; 		//Give player the variable getinfired and time from mission start in seconds TODO Change to serverTime for MP?
			_trackedUnit assignAsCargo _vehicle;					//Assign subject as cargo of the vehicle
			_trackedUnit moveInCargo _vehicle; 						//Move subject into passenger slot
			
			if ((_vehicle getVariable ["_idHoldAction", -1]) isEqualTo -1 ) then { 									 //If vehicles _idHoldAction variable is -1 then
				[_vehicle, true, {}, !(player getVariable ["_vehicleToggle", true])] call BIS_fnc_holdActionVehicle; //Add holdaction to vehicle TODO what does it do?
			};
	}];
	player setVariable ["_idGetInMan", _idGetInMan]; 				// Give player the variable _idGetInMan
};


// GIVE player EVENTHANDLER FOR GETTING OUT OF VEHICLES WITH SUBJECT
if ((player getVariable ["_idGetOutMan", -1]) isEqualTo -1) then { 		//If player has variable _idGetOutMan -1 then

	_idGetOutMan = player addEventHandler ["GetOutMan", { 				//Create eventhandler for every time player gets out of vehicle and call it _idGetOutMan
			params["_unit", "_positon", "_vehicle"]; 					//Parameters from the calling line (subject, position and the vehicle)
			
			if (!(player getVariable ["_vehicleToggle", true])) then { 	//If player dont have _vehicleToggle true 
				_trackedUnit = _unit getVariable "_trackedUnit"; 		//Give _trackedUnit/player the current value from subjects variable _trackedUnit
				unassignVehicle _trackedUnit; 							//Unassign (player?) from vehicle.
				moveOut _trackedUnit;									//Move subject out of vehicle
				[_vehicle, false] call BIS_fnc_holdActionVehicle; 		//Remove action from Vehicle
				};
			}];															//End of eventhandler
	player setVariable ["_idGetOutMan", _idGetOutMan]; 				//Give player the variable _idGetOutMan and start the eventhandler
};