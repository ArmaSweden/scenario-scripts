// functions\sitting\fn_canSit.sqf
/*
Author: Emek1501

Description:
Checks if a player can sit in a specific chair by verifying both the chair's
availability and the player's current sitting status.

Variables:
- _occupied: Boolean indicating if chair is already occupied
- _alreadySitting: Boolean indicating if player is already sitting somewhere
- _canSit: Boolean result of sitting possibility check

Parameters:
0: OBJECT - Chair object to check (Required)
1: OBJECT - Player unit attempting to sit (Required)

Returns:
BOOLEAN - True if player can sit, false otherwise

Important:
- Uses variables "SIT_occupier" on chairs to track occupation
- Uses variables "SIT_sittingData" on players to track sitting state
- Returns false if either chair is occupied or player is already sitting
- Includes detailed debug logging

Notes:
- Called as condition function for ACE interaction
- Variables are checked using isNil for proper null handling
- All checks must pass for sitting to be allowed
- Logs all check results for troubleshooting

Potential Errors:
- Null chair object will cause undefined behavior
- Null player object will cause undefined behavior
- Network sync issues may cause incorrect occupation status
- Variable cleanup issues may cause permanent sitting locks

Example:
// Check if player can sit in nearby chair
private _canSit = [nearestObject [player, "Land_CampingChair_V1_F"], player] call SIT_fnc_canSit;

*/

params [
    ["_chair", objNull, [objNull]], 
    ["_player", objNull, [objNull]]
];

private _occupied = !isNil {_chair getVariable "SIT_occupier"};
private _alreadySitting = !isNil {_player getVariable "SIT_sittingData"};
private _canSit = !_occupied && !_alreadySitting;

diag_log format ["[SIT_fnc_canSit] (INFO) - Chair: %1, Player: %2, Occupied: %3, AlreadySitting: %4, CanSit: %5", 
    _chair, _player, _occupied, _alreadySitting, _canSit];

_canSit