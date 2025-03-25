// fn_escort_stop.sqf

params ["_target", "_caller", "_actionId", "_arguments"];

// Define the condition for showing the action
_conditionShow = "alive _target && player distance _target < 10";

// Define the condition for progressing the action
_conditionProgress = "alive _target && player distance _target < 10";

// Add the hold action
[ 
    _target,
    "stop VIP",
    "images\holdAction_follow_stop.paa",
    "images\holdAction_follow_stop.paa",
    _conditionShow,
    _conditionProgress,
    {},
    {},
    {
        // Stop escorting the VIP
        [[_target, player, 10, [false, false, false]], "scripts\fn_escort.sqf"] remoteExec ["execVM", 0, true];
		[_target] joinSilent grpNull;
		
        // Notify nearby players
        { if (_x distance _target < 20) then { cutText ["VIP: I'll wait here.", "PLAIN"];};} forEach allPlayers;

        // Start escorting the VIP again if needed
        [[_target, player, 10, [true, true, true]], "scripts\fn_escort_follow.sqf"] remoteExec ["execVM", 0, true];
    },
    {},
    [],
    1,
    0
] call BIS_fnc_holdActionAdd;