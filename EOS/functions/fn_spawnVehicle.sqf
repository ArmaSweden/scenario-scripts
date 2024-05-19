/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Skapar fordon och tilldelar besättning baserat på fraktion och typ.

Variables:
- eos_fnc_getunitpool: Funktion som hämtar enhetspool baserat på fraktion och typ.
- lambs_danger_disableAI, lambs_danger_dangerRadio: Variabler för att hantera AI-beteenden.

Remarks:
Skriptet skapar fordon och tilldelar besättning baserat på specifika positioner och egenskaper.

Parameter(s):
- _position: Position där fordonet ska skapas.
- _side: Sida som fordonet tillhör (t.ex. EAST, WEST).
- _faction: Fraktion som enheterna tillhör.
- _type: Typ av enhet som ska skapas.
- _special: Specialparameter för kollisionsegenskaper (default är "CAN_COLLIDE").

Important Notes:
- Fordonstyp och besättning hämtas från enhetspool baserat på fraktion och typ.
- Besättningens AI-beteenden och färdigheter måste vara korrekt inställda för att undvika fel.

Potential Errors:
- Felaktiga fordonstyper eller besättningspositioner kan leda till att fordonet inte skapas korrekt.
- Om enhetspoolen inte är korrekt definierad kan det leda till fel vid skapande av fordon och besättning.

Returns:
- En array som innehåller fordonet, dess besättning och gruppen de tillhör.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_spawnVehicle.sqf] starts at %1", _timestamp];

private _position=(_this select 0);
private _side=(_this select 1);
private _faction=(_this select 2); // fraktionen som enheterna tillhör
private _type=(_this select 3); // typ av enheter som ska skapas
// Hanterar specialparametern som kontrollerar om fordonet kan kollidera med andra objekt
private _special = if (count _this > 4) then {_this select 4} else {"CAN_COLLIDE"};

// Hämtar fordonstypen från en enhetspool baserat på fraktion och typ
private _vehicleType=[_faction,_type] call eos_fnc_getunitpool;
// Skapar en ny grupp för den sida som fordonet tillhör
private _grp = createGroup _side;

// Hämtar möjliga positioner för besättningen inom fordonet
private _vehPositions=[(_vehicleType select 0)] call BIS_fnc_vehicleRoles;
// Skapar själva fordonet på den angivna positionen med den specificerade typen och kollisionsegenskapen
private _vehicle = createVehicle [(_vehicleType select 0), _position, [], 0, _special];

// Array för att hålla reda på alla enheter som tilldelas som besättning i fordonet
private _vehCrew=[];

// Itererar över varje besättningsposition och skapar enheter för varje position
{
	private _currentPosition=_x;
	if (_currentPosition select 0 == "driver")then {
		// Skapa och placera föraren i fordonet
			private ["_unit"];
			_unit = _grp createUnit [(_vehicleType select 1), _position, [], 0, "CAN_COLLIDE"];					
			_unit assignAsDriver _vehicle;
			_unit moveInDriver _vehicle;
			_unit setVariable ["lambs_danger_disableAI", false];
			_unit setVariable ["lambs_danger_dangerRadio", true];
			_vehCrew set [count _vehCrew,_unit];
			};
	
	if (_currentPosition select 0 == "turret")then {
		// Skapa och placera en skytt i en av fordonets tornpositioner
			_unit = _grp createUnit [(_vehicleType select 1), _position, [], 0, "CAN_COLLIDE"];
			_unit assignAsGunner _vehicle;
			_unit MoveInTurret [_vehicle,_currentPosition select 1];
			_unit setVariable ["lambs_danger_disableAI", false];
			_unit setVariable ["lambs_danger_dangerRadio", true];
			_vehCrew set [count _vehCrew,_unit];
			};
			
}foreach _vehPositions;

_grp setVariable ["lambs_danger_enableGroupReinforce", true, true];
_grp setVariable ["lambs_danger_disableGroupAI", false];

// Returnerar fordonet, dess besättning och gruppen de tillhör	
_return=[_vehicle,_vehCrew,_grp];

_return