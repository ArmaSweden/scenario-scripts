// fn_escort_follow.sqf

params ["_target", "_caller", "_actionId", "_arguments"];

// Define the condition for showing the action
_conditionShow = "alive _target && player distance _target < 10";

// Define the condition for progressing the action
_conditionProgress = "alive _target && player distance _target < 10";

// Add the hold action
[ 
    _target,
    "escort VIP",
    "images\holdAction_follow_start.paa",
    "images\holdAction_follow_start.paa",
    _conditionShow,
    _conditionProgress,
    {},
    {},
    {
        // Start escorting the VIP
        [_target] joinSilent _caller;
        [[_target, player, 10, [true, true, true]], "scripts\fn_escort.sqf"] remoteExec ["execVM", 0, true];

        // Notify players nearby
        {
            if (_x distance _target < 20) then {
                cutText ["VIP: Lead the way.", "PLAIN"];
            };
        } forEach allPlayers;

        // Stop escorting the VIP
        [[_target, player, 10, [false, false, false]], "scripts\fn_escort_stop.sqf"] remoteExec ["execVM", 0, true];
    },
    {},
    [],
    1,
    0
] call BIS_fnc_holdActionAdd;