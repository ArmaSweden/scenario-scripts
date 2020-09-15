/*
	Creates a repair zone area for vehicles (not humans).
	
	Put this code in a triggers activation field:	
	[thisList] execVM "scripts\ASE_RepairZone.sqf";
	
	@author Beck [ASE]
*/

params ["_thisList"];

{
	// Do not attempt to repair humans, we've got medic tents for that
	if (_x isKindOf "Man") exitWith {};
	
	_vehicle = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
	_msg = format ["%1 is repaired, refueled and rearmed! Ready to go sir!", _vehicle];
	[[_msg, "PLAIN"]] remoteExec ["titleText", _x];	
	_x setDamage 0;
	_x setFuel 1;
	_x setVehicleAmmo 1;
	
} foreach _thisList;
