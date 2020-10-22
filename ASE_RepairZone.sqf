/*
	Creates a repair zone area for vehicles (not humans).
	
	Put the line of code below in a triggers activation field:	
	
	[thisList] execVM "scripts\ASE_RepairZone.sqf";
	
	@author Beck [ASE]
*/

if (!isServer) exitWith {};

params ["_thisList"];

{
	// Do not attempt to repair humans, we've got medic tents for that
	if (_x isKindOf "Man") exitWith {};
	
	_vehicle = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
	_msg = format ["%1 is repaired, refueled and rearmed! Ready to go sir!", _vehicle];
	[[_msg, "PLAIN"]] remoteExec ["titleText", _x];
	// SetDamage has global arguments and effect so we can run it on the server
	_x setDamage 0;
	// SetFuel and SetVehicleAmmo has to be executed on the client where the vehicle is local (i.e. the drivers client)
	[_x, 1] remoteExec ["setVehicleAmmo", _x]; 
	[_x, 1] remoteExec ["setFuel", _x]; 	
	
} foreach _thisList;
