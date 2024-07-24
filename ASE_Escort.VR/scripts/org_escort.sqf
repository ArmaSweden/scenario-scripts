// POSSIBLE INIT FUNCTIONS THAT COULD CALL THIS SCRIPT
{ [vip, false] execVM "scripts\fn_escortAI.sqf";} remoteExec ["call",0,true];

[_unit false] call BIS_fnc_escortAIHoldAction;

[_unit, true,  compile (format["['%1', 'PROGRESSING'] call bis_fnc_questSetState; ", _templateName])] call BIS_fnc_escortAIHoldAction; 

private _formattedActivation = 
format["_f=%1; _npc=(thisTrigger getVariable '_npc');[_npc, false] call BIS_fnc_escortAIHoldAction;[(thisTrigger getVariable '_templateName'), 'COMPLETED'] call bis_fnc_questSetState;",

waitUntil {_unit = (missionNamespace getVariable [GVAR(_quest, "questNPC"), objNull]); !isNull _unit};
[_unit, false] call BIS_fnc_escortAIHoldAction;

// PARAMETERS FROM NEW INIT LINE (BY DONK)
_unit = _this select 0; //The subject
_toggleOn = _this select 1; //toggleon true or false. False seems to mean activated.



///////////////////////////////////////////////////////////////////////////////////////////////////
//FN_ESCORTAI.SQF  FUNCTIONS FOR FOLLOWING PLAYER AND HANDLING VEHICLES. TODO RUN FROM HOLDACTION OR WHAT?
///////////////////////////////////////////////////////////////////////////////////////////////////

// FUNCTION ESCORTAIVEHICLE. IF PLAYER ON FOOT. SUBJECT OUT OF VEHICLE AND MAKE PLAYER THE FOLLOWED UNIT. TODO Available from other scripts?
BIS_fnc_escortAIVehicle = {										//Name of function
	params["_vehicle", ["_toggleOn", true]];					//Parameters from the calling line (vehicle, [toggleOn, true])
	player setVariable ["_vehicleToggle", _toggleOn];			//Give player the variable from the toggleOn parameter
																//case when the player is outta vehicle
	if (vehicle player isEqualTo player && _toggleOn) then { 	//if player not in vehicle and _toggleOn is true then 
		_trackedUnit = player getVariable "_trackedUnit"; 		//Give _trackedUnit/player the current value from players variable _trackedUnit
		unassignVehicle _trackedUnit; 							//If the unit is currently in that vehicle, the group leader will issue an order to disembark.
		moveOut _trackedUnit; 									//Moves the soldier out of the vehicle
		[_vehicle, false] spawn BIS_fnc_holdActionVehicle; 		//Disable holdaction to vehicle?
	};
};

// HOLDACTION ESCORTAIVEHICLE. IF _toggleHoldAction IS TRUE. REMOVE HOLDACTION FROM VEHICLE AND EMPTY THE VALUES. ELSE SET HOLDACTION ON VEHICLE.
BIS_fnc_holdActionVehicle = {									//Name of function
	params["_vehicle", ["_toggleHoldAction", true], ["_codeOnEnd", {}], ["_toggleOn", true]]; //Parameters from a holdaction?
					// IF _toggleHoldAction IS FALSE. CALL BIS_fnc_escortAIVehicle AND REMOVE _idHoldAction
	if (!_toggleHoldAction) exitWith {							//if _toggleHoldAction is false exit function with these instructions
		[_vehicle, false] call BIS_fnc_escortAIVehicle;			//call BIS_fnc_escortAIVehicle with parameters [_vehicle, false]
		[_vehicle, _vehicle getVariable "_idHoldAction"] call BIS_fnc_holdActionRemove;//remove holdaction _idHoldAction
		_vehicle setVariable ["_idHoldAction", nil];			//set vehicles variable _idHoldAction = empty
		player setVariable ["_vehicleToggle", nil];				//set players value _vehicleToggle = empty
		true};													//exit function
					// AND IS _toggleHoldAction TRUE. SWITCH _idHoldAction VALUES
	_idHoldAction = [_vehicle, "true", "true", BIS_fnc_escortAIVehicle, BIS_fnc_holdActionVehicle, _toggleOn, {}, false]; //Change values on _idHoldAction, maybe reversing follow and stop?
	_vehicle setVariable ["_idHoldAction", _idHoldAction];		//give the vehicle the value _idHoldAction
	player setVariable ["_vehicleToggle", _toggleOn];			//give the player the value _vehicleToggle = true/false
};																//end of function


// ENDING ESCORT
params["_unit", ["_toggleOn", true]];							//Parameters from the calling line (_unit, [_toggleOn, true])
if (!_toggleOn) exitWith {										//if _toggleOn is false exit exit function with these instructions
	doStop _unit;												//Order _unit to stop
	player removeEventHandler ["GetInMan", player getVariable ["_idGetInMan", -1]];  //
	player removeEventHandler ["GetOutMan", player getVariable ["_idGetOutMan", -1]];//
	player setVariable ["_idGetInMan", nil];					//remove variable _idGetInMan
	player setVariable ["_idGetOutMan", nil];					//remove variable _idGetOutMan
	player setVariable ["_npcIsFollowing", nil];				//remove variable _npcIsFollowing
};


// PREPARE SUBJECT TO FOLLOW PLAYER
{deleteWaypoint _x} forEach waypoints group _unit;
_unit setSpeedMode "FULL";						//Bunch of commands for the subject
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
		then {	if (player distance2D _unit >= 5) 								//then if subject is more than 5m away from player
				then { _unit doMove (getPos vehicle player); } 					//make subject go to player
				else {_unit lookAt player; doStop _unit;_unit doFollow _unit; };//Subject look at player and stop; 
		};
		sleep 0.5;
	};
};

player setVariable ["_trackedUnit", _unit]; //Sets player value _trackedUnit = subject


// GIVE PLAYER EVENTHANDLER FOR GETTING INTO VEHICLES WITH SUBJECT
if ((player getVariable ["_idGetInMan", -1]) isEqualTo -1) then {	//If player has variable _idGetInMan -1 then

	_idGetInMan = player addEventHandler ["GetInMan", {  			//Create a trigger every time player gets in vehicle and call it _idGetInMan
			params["_unit", "_positon", "_vehicle"]; 				//Parameters from calling line (subject, position and the vehicle)
			_trackedUnit = _unit getVariable "_trackedUnit";		//Change the subject into Var_trackedUnit and give same string as subject
			_trackedUnit setVariable ["_getInFired", time]; 		//Give player the variable getinfired and time from mission start in seconds TODO Change to serverTime for MP?
			_trackedUnit assignAsCargo _vehicle; 					//Assign subject as cargo of the vehicle
			_trackedUnit moveInCargo _vehicle; 						//Move subject into passenger slot
			
			if ((_vehicle getVariable ["_idHoldAction", -1]) isEqualTo -1 ) then { 									 //If vehicles _idHoldAction variable is -1 then
				[_vehicle, true, {}, !(player getVariable ["_vehicleToggle", true])] call BIS_fnc_holdActionVehicle; //Add holdaction to vehicle TODO what does it do?
			};
	}];
	player setVariable ["_idGetInMan", _idGetInMan]; 				// Give player the variable _idGetInMan and start the eventhandler
};


// GIVE PLAYER EVENTHANDLER FOR GETTING OUT OF VEHICLES WITH SUBJECT
if ((player getVariable ["_idGetOutMan", -1]) isEqualTo -1) then { 		//If player has variable _idGetOutMan -1 then

		_idGetOutMan = player addEventHandler ["GetOutMan", { 			//Create eventhandler for every time player gets out of vehicle and call it _idGetOutMan
			params["_unit", "_positon", "_vehicle"]; 					//Parameters from the calling line (subject, position and the vehicle)
			
			if (!(player getVariable ["_vehicleToggle", true])) then { 	//If player dont have _vehicleToggle true 
				_trackedUnit = _unit getVariable "_trackedUnit"; 		//Give _trackedUnit/player the current value from subjects variable _trackedUnit
				unassignVehicle _trackedUnit; 							//Unassign (player?) from vehicle.
				moveOut _trackedUnit;									//Move subject out of vehicle
				[_vehicle, false] call BIS_fnc_holdActionVehicle; 		//Disable holdaction to vehicle?
				};
			}];															//End of eventhandler
		player setVariable ["_idGetOutMan", _idGetOutMan]; 				//Give player the variable _idGetOutMan and start the eventhandler
};


///////////////////////////////////////////////////////////////////////////////////////////////////
//FN_ESCORTAIHOLDACTION.SQF FUNCTION ?? TODO RUN FROM SCRIPTLINE TO START ESCORT PERSON?
///////////////////////////////////////////////////////////////////////////////////////////////////
#include "..\..\defines\escortAIDefines.inc"; 											//Import definitions for escort (ONLY ESCORT_AI_HOLDACTION)

params["_unit", ["_toggleHoldAction", true], ["_codeOnEnd", {}], ["_toggleOn", true]];	//get parameters from calling line. TODO Holdaction and toggle becomes true?

// REMOVES EVENTHANDLER/HOLDACTION FROM SUBJECT
//if (vehicleVarName _unit isEqualTo "") exitWith {}; 									//TODO no variable name
if (!_toggleHoldAction) exitWith {														//if _toggleHoldAction is false exit with these lines
	[_unit, false] call BIS_fnc_escortAI;												//subject call BIS_fnc_escortAI TODO Function need to be accessible
	[_unit, _unit getVariable "_idHoldAction"] call BIS_fnc_holdActionRemove;			//Remove action from subject
	// _unit setVariable ["_idHoldAction", nil];										//delete subject value for _idHoldAction
	// private _idDeletedHandler = _unit getVariable ["_idDeletedHandler", -1];			//set var _idDeletedHandler to subjects value for _idDeletedHandler
	// if (_idDeletedHandler > -1) then { _unit removeEventHandler ["Deleted", _idDeletedHandler]; };
	// _unit setVariable ["_idDeletedHandler", nil];									//delete subject value _idDeletedHandler
	true
};

// TODO ADD HOLDACTION, VALUES AND EVENTHANDLER ON SUBJECT
private _condition = "alive _target && _this distance _target <= 5";					//_condition becomes holder of action is alive and within 5 meters?
//#define ESCORT_AI_HOLDACTION(target, conditionShow, conditionProgress, fncAI, fncHoldAction, toggle, codeOnEnd, showIcon)\
private _idHoldAction = ESCORT_AI_HOLDACTION(_unit, _condition, _condition, BIS_fnc_escortAI, BIS_fnc_escortAIHoldAction, _toggleOn, _codeOnEnd, true);
																						//Feed values to a holdaction

_unit setVariable ["_idHoldAction", _idHoldAction];										//give subject values "_idHoldAction" = _idHoldAction from addholdaction above
	// EVENTHANDLER WHEN SUBJECT GETS IN VEHICLE
	private _idDeletedHandler = _unit addEventHandler ["Deleted",{						//set eventhandler "Deleted" on subject
		params["_unit"];
		private _getInFired = _unit getVariable ["_getInFired", 0];						//when subject gets into vehicle
		if (_getInFired > 0 && (time-_getInFired) <= 5) exitWith {};					//TODO exit script if it takes too long? TODO serverTime?
	
		_unit setVariable ["_getInFired", nil];											//remove value _getInFired from subject
		[_unit, false] call BIS_fnc_escortAIHoldAction;									//subject calls BIS_fnc_escortAIHoldAction TODO Function need to be accessible

		[vehicleVarName _unit] spawn {													//returns variable name of subject
			params["_unitName"];														//parameter with subjects name
			sleep 2;
			private _unit = objNull;													//remove subject as the
			waitUntil {sleep 0.5; _unit = (missionNamespace getVariable [_unitName, objNull]); !isNull _unit};
			[_unit] call BIS_fnc_escortAIHoldAction; // HOLDACTION ESCORTAIVEHICLE. IF _toggleHoldAction IS TRUE. REMOVE HOLDACTION FROM VEHICLE AND EMPTY THE VALUES. ELSE SET HOLDACTION ON VEHICLE.
		}
	}];
	
_unit setVariable ["_idDeletedHandler", _idDeletedHandler];								// Give subject value "_idDeletedHandler" for later deletion

///////////////////////////////////////////////////////////////////////////////////////////////////
//HOLDACTION QUESTINIT.SQF FUNCTION: START A QUEST. INITIATE ESCORT FROM QUESTSCRIPT? SET A QUEST ON THE SUBJECT.
///////////////////////////////////////////////////////////////////////////////////////////////////
#include "\A3\Missions_F_Oldman\Systems\defines\questDefines.inc";

//Parameters from calling line that gives areainfo and quest TODO Not needed?
params[["_areaInfo", [], [ [] ]], "_quest"];

private _allObjects = GVARS(_quest, "allObjects", [objNull]); //Macro about questobjects
private _apos = (_allObjects#0); //give apos positions for all quest objects

// TODO
_this spawn {
	private _quest = _this#1;
	private _questObjectName = GVAR(_quest, "questNPC"); //set quest on the questnpc(subject)
	
	private _questInitCode = { //code that runs when quest starts
	
		params["_quest", ["_questObject", objNull]];
	
		if (isNull _questObject) exitWith {}; //exit if there is no questobject
		private _templateName = GVAR(_quest, "currentTemplateName"); //Macro for template
		private _questType = GVAR(_quest, "questType"); //macro for type of quest #define QUEST_TYPE_TRANSPORT_PERSON = 4
		// _templateName, _container, _itemTypes, _itemCount, GVAR(_container, "QuestType")/ Arguments passed to the scripts as _this select 3
	
		//TODO
		private _specificProperies = (GVAR(_quest, "specificProperties"))#1;
		_specificProperies params["_holdActionIcon", "_holdActionEndedQuestState", "_holdActionDistance", "_holdActionAdditionalCondition", "_holdActionProgressingCondition", "_holdActionCode","_holdActionOnPlayer"];
		//TODO
		private _holdActionTarget = if ((call compile _holdActionOnPlayer)) then {player} else {_questObject};
		private _holdActionCondition = format["player distance %1 < %2 && %3", _questObject, _holdActionDistance, _holdActionAdditionalCondition]; //TODO hardcoded distance + && customCondition
	
				private _actionId = [
				_holdActionTarget, 			// Object the action is attached to
				GVAR(_quest, "title"),    	// Title of the action
				_holdActionIcon,           	// Idleicon shown on screen
				_holdActionIcon,       		// Progress icon shown on screen
				_holdActionCondition,
				_holdActionProgressingCondition,  // Condition for the action to progress 
				{},							//--- when hold action starts
				{},							//TODO make it as progressing state
				{	_arguments params["_templateName", "_holdActionEndedQuestState", "_holdActionCode"];//--- when holdaction ends
					[_templateName,  2] call bis_fnc_questSetState; //TODO using this to hit a progressing state
					sleep 0.5;
					[] call compile _holdActionCode;
					if (_holdActionEndedQuestState != "") then {
						[_templateName, _holdActionEndedQuestState] spawn bis_fnc_questSetState;
					};
				},//--- when holdaction ends, ends here
				{},//--- when action is terminated
				[GVAR(_quest, "currentTemplateName"), _holdActionEndedQuestState, _holdActionCode], // _templateName, _container, _itemTypes, _itemCount, GVAR(_container, "QuestType")/ Arguments passed to the scripts as _this select 3
				1,	   // Time
				0,	   // Priority
				true,  // Remove on completion
				true  // Show in unconscious statee
				] call BIS_fnc_holdActionAdd;
	};
	
	[_quest, MGVARS(_questObjectName, objNull)] call _questInitCode;
	private _questId =  GVAR(_quest, "questId");
	private _ehId = [_questObjectName,  compile format["[([%1] call bis_fnc_questData), _this#0] call %2", _questId, _questInitCode] ] call BIS_fnc_om_spawn_addInitEventHandler;
	SVAR(_quest, "ehId" , _ehId);
};
_apos


///////////////////////////////////////////////////////////////////////////////////////////////////
//HOLDACTION QUESTINIT.SQF FUNCTION: TRIGGER QUEST INIT
///////////////////////////////////////////////////////////////////////////////////////////////////
#include "\A3\Missions_F_Oldman\Systems\defines\questDefines.inc";

params[["_areaInfo", [], [ [] ]],"_quest"];

private _templateName = GVAR(_quest, "currentTemplateName");
private _questType = GVAR(_quest, "questType");

_areaInfo params["_syncObjects", "_markerParams"];

private _area = _syncObjects getVariable "objectArea";
private _apos = getPos _syncObjects;
deleteVehicle _syncObjects;

//["quest TRANSPORT INIT %1 %2", _area, _apos] call bis_fnc_logFormat;

private _questNpc = GVAR(_quest, "questNPC");
SVAR(_quest, "runFinishedStateAlways", true);

[_questNpc, _templateName] spawn {
	params["_questNpc", "_templateName"];
	private _unit = objNull;
	private _sector = objNull;
	waitUntil {sleep 0.5; _unit = (missionNamespace getVariable [_questNpc, objNull]); !isNull _unit && {_sector = (group _unit getVariable ["#sector", objNull]); !isNull _sector} };
	[_unit, true,  compile (format["['%1', 'PROGRESSING'] call bis_fnc_questSetState; ", _templateName])] call BIS_fnc_escortAIHoldAction;
	//[_unit, _sector] call BIS_fnc_om_removeFromSector;
};

//CREATE TRIGGER 
private _triggerCheckCheckpoint = createTrigger ["EmptyDetector", _apos];
_triggerCheckCheckpoint setTriggerArea _area;
_triggerCheckCheckpoint setTriggerTimeout [0, 0, 0, true];
_triggerCheckCheckpoint setTriggerActivation ["ANY", "PRESENT", true]; 
SVAR(_triggerCheckCheckpoint, "_questNpc" , _questNpc);
SVAR(_triggerCheckCheckpoint, "_templateName" , _templateName);

//INITIATE ESCORT HOLDACTION
private _formattedActivation = format["_f=%1; _npc=(thisTrigger getVariable '_npc');[_npc, false] call BIS_fnc_escortAIHoldAction;[(thisTrigger getVariable '_templateName'), 'COMPLETED'] call bis_fnc_questSetState;",
 [_templateName, [] ,_questType, [] ]];
 
_triggerCheckCheckpoint setTriggerStatements [
"_npc = missionNamespace getVariable (thisTrigger getVariable '_questNpc'); 
 thisTrigger setVariable ['_npc', _npc];if (!(isNull _npc) && !(alive _npc)) then { [thisTrigger getVariable '_templateName', 6] call bis_fnc_questSetState; };_npc in (list thisTrigger)"
, _formattedActivation, ""];

SVAR(_quest, "_triggerCheckCheckpoint", _triggerCheckCheckpoint);
_apos


///////////////////////////////////////////////////////////////////////////////////////////////////
//HOLDACTION QUESTFINISHED.SQF FUNCTION: END QUEST WHEN COMPLETE
///////////////////////////////////////////////////////////////////////////////////////////////////
#include "\A3\Missions_F_Oldman\Systems\defines\questDefines.inc";
params["_quest", "_eventData"];
// QUEST_DATA_UNPACK(_questData);
private _unit = objNull;
waitUntil {_unit = (missionNamespace getVariable [GVAR(_quest, "questNPC"), objNull]); !isNull _unit};
[_unit, false] call BIS_fnc_escortAIHoldAction;
// deleteVehicle (GVAR(_quest, "_triggerCheckCheckpoint", false));
true