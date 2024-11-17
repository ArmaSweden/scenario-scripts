// functions\sitting\fn_sit.sqf
/*
Author: Emek1501

Description:
Handles the complete sitting process for a player on a specific chair object. 
Manages position attachment, animation, camera settings, and interaction menu updates.

Variables:
- _chairType: String containing the chair's classname
- _configFile: Config path to chair settings
- _sitPosition: Array [x,y,z] of sitting position offset
- _sitDirection: Number indicating sitting direction offset
- _animation: String containing selected sitting animation
- _standAction: ACE interaction action for standing up
- _originalViewControl: Stored player's original view distance

Parameters:
0: OBJECT - Target chair to sit on (Required)
1: OBJECT - Player unit that will sit (Required)

Returns:
None

Important:
- Must be executed on player's machine (uses remoteExec if needed)
- Requires valid chair configuration in CfgSitting
- Sets up Per Frame Handler to monitor sitting state
- Manages ACE interaction menu actions
- Handles network synchronization of variables

Notes:
- Checks for local execution and redirects if necessary
- Validates all parameters before execution
- Attaches player to chair with configured offset
- Adds self-interaction for standing up
- Enables external camera view
- Sets up continuous monitoring of chair existence

Potential Errors:
- Invalid chair configuration will exit function
- Network sync issues may cause desync between clients
- Chair deletion while sitting requires special handling
- Animation transitions might not be smooth on high latency
- Camera view changes might disorient players

Example:
// Make player sit on nearest chair
[nearestObject [player, "Land_CampingChair_V1_F"], player] call SIT_fnc_sit;

*/

params [
    ["_target", objNull, [objNull]], 
    ["_player", objNull, [objNull]]
];

if (isNull _target || isNull _player) exitWith {
    diag_log "[SIT_fnc_sit] (INFO): Invalid parameters passed to sit function";
};

if (!local _player) exitWith {
    [_target, _player] remoteExec ["SIT_fnc_sit", _player];
};

private _chairType = typeOf _target;
diag_log format ["[SIT] Attempting to sit on chair type: %1", _chairType];

// Get chair configuration
private _configFile = missionConfigFile >> "CfgSitting" >> "ChairTypes" >> _chairType;
if (!isClass _configFile) exitWith {
    diag_log format ["[SIT] No config found for chair type: %1", _chairType];
};

private _sitPosition = getArray (_configFile >> "sitPosition");
if (count _sitPosition != 3) exitWith {
    diag_log format ["[SIT] Invalid sit position for chair type: %1 - Position: %2", _chairType, _sitPosition];
};

private _sitDirection = getNumber (_configFile >> "sitDirection");

// Prevent multiple people from sitting
_target setVariable ["SIT_occupier", _player, true];

// Apply sitting animation first
private _animation = [] call SIT_fnc_getRandomAnimation;
diag_log format ["[SIT] Selected animation: %1", _animation];

// Set position and direction before animation
_player attachTo [_target, _sitPosition];
[_player, ((getDir _target) + _sitDirection)] remoteExec ["setDir", _player];

// Add stand up action (changed to ACE self-interaction)
private _standAction = [
    "SIT_StandUp",
    "Stand Up",
    "\a3\ui_f\data\IGUI\Cfg\Actions\getInCargo_ca.paa",
    {
        params ["_target"];
        [_target] call SIT_fnc_stand;
    },
    {_this call SIT_fnc_canStand}
] call ace_interact_menu_fnc_createAction;

[_player, 1, ["ACE_SelfActions"], _standAction] call ace_interact_menu_fnc_addActionToObject;

// Save sitting data before animation
_player setVariable ["SIT_sittingData", [_target, "SIT_StandUp"], true];

// Apply animation last
[_player, _animation] remoteExec ["switchMove", 0];
[_player, _animation] remoteExec ["playMove", 0];

// Enable free look while sitting
_player enableAI "ANIM";
_player setVariable ["SIT_originalViewControl", viewDistance];
_player switchCamera "EXTERNAL";

[{
    params ["_args", "_handle"];
    _args params ["_player", "_chair"];
    
    // Remove PFH if not sitting anymore
    if (isNil {_player getVariable "SIT_sittingData"}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        diag_log "[SIT] PFH: Removed due to nil sitting data";
    };
    
    // Only check if chair exists
    if (isNull _chair) then {
        [_player] call SIT_fnc_stand;
        diag_log "[SIT] PFH: Chair no longer exists";
    };
}, 0.5, [_player, _target]] call CBA_fnc_addPerFrameHandler;

diag_log "[SIT_fnc_sit] (INFO): Completed sitting sequence";