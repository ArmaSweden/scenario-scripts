/*
	Heals humans entering the trigger area.
	
	Put the line of code below in a triggers activation field:
	
	[thisList] execVM "scripts\ASE_MedicZone.sqf";
	
	@author Beck [ASE]
*/

params ["_thisList"];

{ 
	// Do not attempt to heal non-humans
	if !(_x isKindOf "Man") exitWith {};
	
	[objNull, _x] call ace_medical_treatment_fnc_fullHeal; 
	_msg = "Doctor: you are ready to go solider, godspeed!"; 
	[[_msg, "PLAIN"]] remoteExec ["titleText", _x]; 
 
} forEach thisList;