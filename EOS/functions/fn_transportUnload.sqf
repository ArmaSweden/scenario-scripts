/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hanterar avlastning av enheter från transportfordon, inklusive landning och CQB-uppgifter.

Variables:
- EOS_debug: Funktion för att skapa debug-markörer.
- lambs_danger_enableGroupReinforce, lambs_danger_disableGroupAI: Variabler för att hantera AI-beteenden.

Remarks:
Skriptet skapar landningsplatser, sätter waypoints för landning och avlastning, och hanterar avlastning av enheter samt tilldelar CQB-uppgifter.

Parameter(s):
- _mkr: Markör för landningsposition.
- _veh: Fordonsinformation (array som innehåller fordon, grupp och besättning).
- _counter: Räknare för att spåra avlastningsoperationen.

Important Notes:
- Landningsplatser och waypoints måste vara korrekt inställda för att avlastning ska fungera smidigt.
- Debugging kan aktiveras för att logga avlastningsoperationen och skapa markörer.

Potential Errors:
- Om landningsplatsen inte är korrekt definierad kan fordonet misslyckas med att landa och avlasta enheter.
- Felaktiga waypoints kan leda till att enheterna inte avlastas korrekt.

Returns:
- Inga specifika returer, enheterna avlastas och tilldelas CQB-uppgifter.
*/


// Initierar tidsstämpel och loggar start av skriptet.
private _timeStamp = diag_tickTime;
diag_log format ["[fn_transportUnload.sqf] starts at %1", _timestamp];

// Deklarerar och tilldelar ingångsparametrar.
private ["_pad", "_getToMarker", "_cargoGrp", "_vehicle"];
_mkr = (_this select 0);
_veh = (_this select 1);
_counter = (_this select 2);

// Debug-läge aktiverat.
_debug = true;
_vehicle = _veh select 0;
_grp = _veh select 2;
_cargoGrp = _veh select 3;
_pos = [_mkr, false] call eos_fnc_pos;									

// Skapar landningsplatta och loggar om debug är aktiverat.
_pad = createVehicle ["Land_HelipadEmpty_F", _pos, [], 0, "NONE"];
if (_debug) then {
    0 = [_mkr, _counter, "Unload Pad", (getPos _pad)] call EOS_debug;
};
		
// Tilldelar AI-inställningar till grupperna.
{_x allowFleeing 0} forEach units _grp;
{_x setVariable ["lambs_danger_dangerRadio", true];} forEach units _grp;
{_x allowFleeing 0} forEach units _cargoGrp;
{_x setVariable ["lambs_danger_dangerRadio", true];} forEach units _cargoGrp;

_grp setVariable ["lambs_danger_enableGroupReinforce", true, true];
_grp setVariable ["lambs_danger_disableGroupAI", false];
_cargoGrp setVariable ["lambs_danger_enableGroupReinforce", true, true];
_cargoGrp setVariable ["lambs_danger_disableGroupAI", false];
 
// Skapar waypoint för landning.
_wp1 = _grp addWaypoint [_pos, 0];  
_wp1 setWaypointSpeed "FULL";  
_wp1 setWaypointType "UNLOAD";
_wp1 setWaypointStatements ["true", "(vehicle this) LAND 'GET IN';"]; 

// Väntar tills fordonet når landningsplatsen och avlastar enheter.
 waituntil {_vehicle distance _pad < 30};
_cargoGrp leaveVehicle _vehicle;	

// Väntar tills alla enheter har avlastats.		
waitUntil{sleep 0.2; {_x in _vehicle} count units _cargoGrp == 0};				
if (_debug) then {
	hint "Transport unloaded";
};

// Tilldelar CQB-uppgift till avlastade enheter.
0 = [_cargoGrp, _mkr, 500, 21, [], true] spawn lambs_wp_fnc_taskCQB;

// Skapar ny waypoint för fordonet och rensar besättning.						
_wp2 = _grp addWaypoint [[0,0,0], 0];  
_wp2 setWaypointSpeed "FULL";  
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "{deleteVehicle _x} forEach crew (vehicle this) + [vehicle this];"];  

// Rensar landningsplattan.
deletevehicle _pad;