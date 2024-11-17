// functions\helper\fn_switchAnimation.sqf
/*
Author: Emek1501

Description:
Applies an animation to a unit using both switchMove and playMoveNow commands to ensure
smooth animation transitions. Includes logging for debugging purposes.

Variables:
- _unit: The unit to apply the animation to
- _animation: The animation classname to be played

Parameters:
0: OBJECT - Unit to animate (Required)
1: STRING - Animation classname (Required)

Returns:
None

Important:
- Both unit and animation parameters are required
- Uses both switchMove and playMoveNow for reliable animation switching
- Includes debug logging for troubleshooting

Notes:
- Function performs input validation before executing
- Logs all animation attempts including failures
- Uses params array for parameter validation

Potential Errors:
- Passing null unit will exit with log message
- Passing empty animation string will exit with log message
- Invalid animation classnames may cause animation failures
- Network sync issues may cause delayed or failed animations

Example:
// Switch player to sitting animation
[player, "HubSittingChairA_idle1"] call SIT_fnc_switchAnimation;

*/

params [
    ["_unit", objNull, [objNull]],
    ["_animation", "", [""]]
];

if (isNull _unit) exitWith {
    diag_log "[SIT_fnc_switchAnimation] (INFO): Null unit passed";
};

if (_animation == "") exitWith {
    diag_log "[SIT_fnc_switchAnimation] (INFO): Empty animation passed";
};

_unit switchMove _animation;
_unit playMoveNow _animation;

diag_log format ["[SIT_fnc_switchAnimation] (INFO): Applied animation %1 to unit %2", _animation, _unit];