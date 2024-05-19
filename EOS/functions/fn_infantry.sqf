/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Skapar infanterigrupper baserat på angiven fraktion och typ, och hanterar deras beteenden och roller inom en specifik zon.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _grp: Den skapade infanterigruppen.
- _units: Array med enheter som tillhör infanterigruppen.
- _position: Position där infanterigruppen ska skapas.
- _size: Storlek på infanterigruppen.

Remarks:
Skriptet hanterar skapandet av infanterigrupper, tilldelar dem rätt roller och beteenden, och placerar dem inom en angiven zon.

Parameter(s):
- _position: Position där infanterigruppen ska skapas.
- _size: Storlek på infanterigruppen.
- _faction: Fraktionen som enheterna tillhör.
- _side: Sida som enheterna tillhör (t.ex. EAST, WEST).

Important Notes:
- Position och storlek måste vara korrekt definierade för att säkerställa att gruppen skapas korrekt.
- AI-beteenden och roller måste vara korrekt inställda för att undvika konflikter och oväntade beteenden.

Potential Errors:
- Om positionen inte är säker eller korrekt definierad kan enheterna skapas på fel plats eller inte alls.
- Felaktigt definierade roller kan leda till att enheterna inte beter sig som förväntat.

Returns:
- Returnerar den skapade infanterigruppen.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_infantry.sqf] starts at %1", _timestamp];

if (!isServer) then {
	diag_log "Denna kod måste köras på servern";
} else {
	// SINGLE INFANTRY GROUP
	private ["_grp","_unit","_pool","_pos","_faction"];
	//Definiera parametrarna för funktionen
	_pos=(_this select 0);
	_grpSize=(_this select 1);
	_faction=(_this select 2);
	_side=(_this select 3);
	//Beräkna storleken på gruppen baserat på inskickade parametrar
	_grpMin=_grpSize select 0;
	_grpMax=_grpSize select 1;
	_d=_grpMax-_grpMin;				
	_r=floor(random _d);							
	_grpSize=_r+_grpMin;
		//Hämta enhetstyp baserat på om enheten är i vatten eller på land
		if (surfaceiswater _pos) then {
			_pool=[_faction,1] call eos_fnc_getunitpool;
		} else { 
			_pool=[_faction,0] call eos_fnc_getunitpool;
		};
		//Skapa en ny grupp
		_grp=createGroup _side;
	//Iterera över antalet enheter som ska skapas
	for "_x" from 1 to _grpSize do {					
			_unitType=_pool select (floor(random(count _pool)));
			_unit = _grp createUnit [_unitType, _pos, [], 6, "FORM"];
			_unit setVariable ["lambs_danger_dangerRadio", true];
		};
		//LAMBS inställningar
		_grp setVariable ["lambs_danger_disableGroupAI", false];
		_grp setVariable ["lambs_danger_enableGroupReinforce", true, true];

	_grp;
};