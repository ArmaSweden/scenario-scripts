// SETTING UP MISSION AND TASK
// VARIABLES
vipHouse = "VIP_1";
publicVariable "vipHouse";

// CREATE TASK
_taskTitle = "VIP escort";
format ["Escort the VIP to the blue arrow."] remoteExec ["hint", 0];
_taskDescription = "Use the holdaction on the VIP and escort him to the blue arrow.";
[west, "VIP escort", [_taskDescription, "Escort the VIP"], [vip], "CREATED", 0, true] call BIS_fnc_taskCreate;

// FUNCTION FOR FAILING MISSION
failedMission = {[_taskTitle,"FAILED",true] call BIS_fnc_taskSetState;};

// START ESCORT SCRIPT. SUBJECT BECOMES ESCORTABLE
// DELAY FOR STARTING ESCORT
waitUntil {player distance vip < 10}; // Removed sleep for immediate checking

// THIS LINE IS NEEDED TO START THE FUNCTION
[vip, "scripts\fn_escort_follow.sqf"] remoteExec ["execVM",0,true];
[vip2, "scripts\fn_escort_follow.sqf"] remoteExec ["execVM",0,true];

// INDICATION THAT ESCORT IS ACTIVE
{ cutText ["Escort started", "PLAIN"]; } remoteExec ["call", call BIS_fnc_listPlayers];

// REACH DESTINATION
waitUntil { (getMarkerPos vipHouse) distance vip < 3 || !alive vip }; // Removed sleep for immediate checking
if (!alive vip) exitWith {call failedMission; sleep 5; endMission "LOSER";};
hint "Destination reached";

// END ESCORT SCRIPT. SUBJECT IS NO LONGER ESCORTABLE
{ [vip, _user, 10, [false,false,false]] execVM "scripts\fn_escort.sqf"; } remoteExec ["call", 0, true];
{ removeAllActions vip; } remoteExec ["call", 0, true];

// GOODBYE MESSAGE AND TASK COMPLETED
{ cutText ["Thank you for your service.", "PLAIN"]; } remoteExec ["call", call BIS_fnc_listPlayers select { _x distance vip < 20 }];
hint "Task completed";
sleep 2;

// ENDING TASK AND MISSION
// TASK SUCCEED
[_taskTitle,"SUCCEEDED",true] call BIS_fnc_taskSetState;
sleep 5;
endMission "END1";