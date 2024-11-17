// functions\sitting\fn_canStand.sqf
/*
Author: Emek1501

Description:
Checks if a player is currently sitting and therefore able to stand up.
Used as a condition check for the stand-up action.

Variables:
- _canStand: Boolean indicating if player can perform stand action

Parameters:
0: OBJECT - Player unit to check (Required)

Returns:
BOOLEAN - True if player can stand (is sitting), false otherwise

Important:
- Uses variable "SIT_sittingData" to determine sitting state
- Returns true only if player has sitting data
- Includes debug logging for troubleshooting

Notes:
- Called as condition function for ACE interaction
- Simple check that only verifies sitting status
- Variable check uses isNil for proper null handling
- Logs check result for debugging purposes

Potential Errors:
- Null player object will cause undefined behavior
- Variable cleanup issues may cause incorrect sitting state detection
- Network sync issues may cause delayed state updates

Example:
// Check if player can stand up
private _canStand = [player] call SIT_fnc_canStand;

*/

params [
    ["_player", objNull, [objNull]]
];

private _canStand = !isNil {_player getVariable "SIT_sittingData"};
diag_log format ["[SIT_fnc_canStand] (INFO) check: %1", _canStand];
_canStand