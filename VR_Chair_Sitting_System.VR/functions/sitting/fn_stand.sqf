// functions\sitting\fn_stand.sqf
/*
Author: Emek1501

Description:
Handles the complete process of a player standing up from a sitting position.
Manages animation transitions, variable cleanup, and interaction menu updates.

Variables:
- _sittingData: Array containing [chair object, action ID]
- _animation: String containing appropriate standing animation based on weapon state

Parameters:
0: OBJECT - Player unit that will stand up (Required)

Returns:
None

Important:
- Must be executed on player's machine (uses remoteExec if needed)
- Cleans up all sitting-related variables
- Removes ACE self-interaction menu items
- Restores default camera view and controls
- Selects appropriate standing animation based on current weapon

Notes:
- Checks for local execution and redirects if necessary
- Validates sitting data before execution
- Handles chair variable cleanup even if chair is deleted
- Uses different animations for different weapon states:
 * No weapon: "amovpercmstpsnonwnondnon"
 * Primary weapon: "amovpercmstpslowwrfldnon"
 * Handgun: "amovpercmstpslowwpstdnon"
- Includes debug logging

Potential Errors:
- Network sync issues may cause variable cleanup failures
- Animation transitions might not be smooth on high latency
- Missing sitting data will exit function
- Camera transition might temporarily disorient players
- Weapon state detection might fail in edge cases

Example:
// Make player stand up
[player] call SIT_fnc_stand;

*/

params [
    ["_player", objNull, [objNull]]
];

if (!local _player) exitWith {
    [_player] remoteExec ["SIT_fnc_stand", _player];
};

// Get sitting data
private _sittingData = _player getVariable ["SIT_sittingData", []];
if (_sittingData isEqualTo []) exitWith {
    diag_log "[SIT_fnc_stand] (INFO): No sitting data found";
};

_sittingData params [["_chair", objNull, [objNull]], ["_actionId", "", [""]]];

// Remove ACE self-interaction
[_player, 1, ["ACE_SelfActions", _actionId]] call ace_interact_menu_fnc_removeActionFromObject;

// Clear variables
_player setVariable ["SIT_sittingData", nil, true];
if (!isNull _chair) then {
    _chair setVariable ["SIT_occupier", nil, true];
};

// Restore camera and controls
_player switchCamera "INTERNAL";
_player enableAI "ALL";

// Detach and reset position
detach _player;

// Restore animation based on weapon
private _animation = switch (currentWeapon _player) do {
    case "": {"amovpercmstpsnonwnondnon"};
    case (primaryWeapon _player): {"amovpercmstpslowwrfldnon"};
    case (handgunWeapon _player): {"amovpercmstpslowwpstdnon"};
    default {"amovpercmstpsnonwnondnon"};
};

// Apply stand animation
[_player, _animation] remoteExec ["switchMove", 0];

diag_log "[SIT_fnc_stand] (INFO): Player stood up successfully";