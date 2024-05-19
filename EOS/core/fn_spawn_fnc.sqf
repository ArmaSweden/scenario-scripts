/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Kompilerar och exekverar olika spawn-funktioner som används av EOS.

Variables:
- eos_fnc_spawnvehicle_path, eos_fnc_grouphandlers_path: Sökvägar till funktionerna som ska kompileras.

Remarks:
Skriptet kontrollerar och kompilerar funktioner som används för att spawna fordon, sätta grupphanterare, hitta säkra positioner, spawna grupper, sätta cargo och få enhetspooler.

Important Notes:
- Funktionerna måste vara korrekt definierade och deras sökvägar måste vara korrekta för att undvika fel vid kompilerings- och exekveringstid.

Potential Errors:
- Om sökvägarna till funktionerna inte är korrekta kan det leda till fel vid kompilerings- och exekveringstid.
- Dubbel deklaration av funktioner kan leda till oväntade beteenden.

Returns:
- Inga specifika returer, funktioner kompileras och exekveras vid behov.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_spawn_fnc.sqf] starts at %1", _timestamp];

// Kontrollera och kompilera funktioner endast om de inte redan är definierade

// Funktion för att spawna fordon
if (isNil "eos_fnc_spawnvehicle") then {
    eos_fnc_spawnvehicle = compileFinal preprocessFileLineNumbers eos_fnc_spawnvehicle_path;
};

// Funktion för att ställa in grupphanterare
if (isNil "eos_fnc_grouphandlers") then {
    eos_fnc_grouphandlers = compileFinal preprocessFileLineNumbers eos_fnc_grouphandlers_path;
};

// Funktion för att hitta en säker position
if (isNil "eos_fnc_findsafepos") then {
    eos_fnc_findsafepos = compileFinal preprocessFileLineNumbers eos_fnc_findsafepos_path;
};

// Funktion för att spawna grupper
if (isNil "eos_fnc_spawngroup") then {
    eos_fnc_spawngroup = compileFinal preprocessFileLineNumbers eos_fnc_spawngroup_path;
};

// Funktion för att sätta cargo i fordon
if (isNil "eos_fnc_setcargo") then {
    eos_fnc_setcargo = compileFinal preprocessFileLineNumbers eos_fnc_setcargo_path;
};

// Funktion för att få positioner
if (isNil "eos_fnc_pos") then {
    eos_fnc_pos = compileFinal preprocessFileLineNumbers eos_fnc_pos_path;
};

// Funktion för att få enhetspooler
if (isNil "eos_fnc_getunitpool") then {
    eos_fnc_getunitpool = compileFinal preprocessFileLineNumbers eos_fnc_getunitpool_path;
};

// Kompilera och exekvera AI-färdigheter från en specifik fil
call compile preprocessfilelinenumbers EOS_AI_Skills_path;

// Hämta färger för markörer från missionNamespace
private _hostileColor = missionNamespace getVariable ["hostileColor", "colorRed"];
private _bastionColor = missionNamespace getVariable ["bastionColor", "colorOrange"];

// Funktion för att deaktivera markörer
EOS_Deactivate = {
	private ["_mkr"];
		_mkr=(_this select 0);	 // Hämta markören från funktionens argument	
	{
		_x setmarkercolor "colorblack";
		_x setmarkerAlpha 0.25;
	}foreach _mkr;
};

// Funktion för att aktivera markörer som fientliga
EOS_Activate = {
	private ["_mkr"];
		_mkr=(_this select 0); // Hämta markören från funktionens argument		
	{
		_x setmarkercolor "_hostileColor";
		_x setmarkerAlpha 0.1;
	}foreach _mkr;
};

// Funktion för att aktivera bastionsmarkörer
EOS_BASActivate = {
	private ["_mkr"];
		_mkr=(_this select 0); // Hämta markören från funktionens argument		
	{
		_x setmarkercolor "_bastionColor";
		_x setmarkerAlpha 0.1;
	}foreach _mkr;
};

// Funktion för att skapa debug-markörer
EOS_debug = {
private ["_note"];
_mkr=(_this select 0);
_n=(_this select 1);
_note=(_this select 2);
_pos=(_this select 3);

_mkrID=format ["%3:%1,%2",_mkr,_n,_note];
deletemarker _mkrID; // Radera eventuell befintlig markör med samma ID
_debugMkr = createMarker[_mkrID,_pos];
_mkrID setMarkerType "Mil_dot";
_mkrID setMarkercolor "colorBlue";
_mkrID setMarkerText _mkrID;
_mkrID setMarkerAlpha 0.5;
};