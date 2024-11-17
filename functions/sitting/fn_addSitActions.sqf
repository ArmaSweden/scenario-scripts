// functions\sitting\fn_addSitActions.sqf
/*
Author: Emek1501

Description:
Creates and adds ACE interaction menu actions for sitting to specified chair classes. 
The function adds both class-wide actions and updates existing objects within player range.

Variables:
- _class: Chair classname to add actions to
- _sitAction: ACE interaction action object for sitting

Parameters:
0: STRING - Classname of the chair type (Required)

Returns:
None

Important:
- Requires ACE Interaction Menu
- Adds actions to both class definition and existing objects
- Only processes objects within 50m of player
- Only runs on machines with interface (players)

Notes:
- Creates unique action ID for each chair type
- Uses Swedish text "Sitt ner" for action name
- Includes condition check through fn_canSit
- Uses standard A3 cargo icon for visual identification
- Includes debug logging

Potential Errors:
- Empty classname will exit with log message
- Missing ACE mod will cause script errors
- Missing required functions (SIT_fnc_sit, SIT_fnc_canSit) will cause errors
- Network sync issues may cause delayed action appearance

Example:
// Add sit actions to camping chair
["Land_CampingChair_V1_F"] call SIT_fnc_addSitActions;

*/

params [
    ["_class", "", [""]]
];

if (_class == "") exitWith {
    diag_log "[SIT_fnc_addSitActions] Empty class name passed";
};

diag_log format ["[SIT_fnc_addSitActions] Processing class: %1", _class];

private _sitAction = [
    format ["SIT_Action_%1", _class],
    "Sitt ner",
    "\a3\ui_f\data\IGUI\Cfg\Actions\getInCargo_ca.paa",
    {
        _this call SIT_fnc_sit;
    },
    {
        _this call SIT_fnc_canSit;
    }
] call ace_interact_menu_fnc_createAction;

[_class, 0, ["ACE_MainActions"], _sitAction] call ace_interact_menu_fnc_addActionToClass;

if (hasInterface) then {
    {
        if (typeOf _x == _class) then {
            [_x, 0, ["ACE_MainActions"], _sitAction] call ace_interact_menu_fnc_addActionToObject;
        };
    } forEach (nearestObjects [player, [_class], 50]);
};

diag_log format ["[SIT_fnc_addSitActions] Added actions to class: %1", _class];