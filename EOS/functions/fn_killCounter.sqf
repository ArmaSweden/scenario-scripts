/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hanterar räkning av dödade enheter och loggar denna information för analys och debugging.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _unit: Den enhet som dödats.
- _killer: Den enhet som dödade _unit.
- _killCount: Total antal dödade enheter.

Remarks:
Skriptet lägger till en event handler som räknar och loggar varje gång en enhet dödas, samt uppdaterar en global variabel med den totala kill count.

Parameter(s):
- _unit: Den enhet som dödats.
- _killer: Den enhet som dödade _unit.

Important Notes:
- Event handlern måste vara korrekt tillagd för varje enhet som ska räknas.
- Den globala variabeln för kill count måste vara korrekt definierad och uppdaterad.

Potential Errors:
- Om event handlern inte är korrekt tillagd kommer dödade enheter inte att räknas.
- Felaktigt definierade enheter kan leda till att felaktiga kill counts loggas.

Returns:
- Inga specifika returer, kill count uppdateras globalt.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_killCounter.sqf] starts at %1", _timestamp];

// Nyare syntax för att deklarera privata variabler
_eosKills = missionNamespace getVariable ["EOSkillCounter", 0];

// Öka räknaren
_eosKills = _eosKills + 1;

// Uppdatera den globala variabeln
missionNamespace setVariable ["EOSkillCounter", _eosKills, true];

// Visa antal dödade enheter
hint format ["Units Killed: %1", _eosKills];