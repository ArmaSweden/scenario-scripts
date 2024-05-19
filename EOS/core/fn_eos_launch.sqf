/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Startar och konfigurerar EOS-zoner, genererar och hanterar grupper av fiender baserat på specifika inställningar och sannolikheter.

Variables:
- EOSmarkers: En lista över EOS-markörer som används för att spåra aktiva zoner.
- x_reload_time_factor: Justerar fördröjningen vid omfattande service.

Remarks:
Skriptet hanterar initiering av EOS-zoner, generering av enheter, och deras patrullering inom zonen.

Parameter(s):
- _JIPmkr: JIP-markörer (Join-In-Progress).
- _HouseInfantry: Inställningar för husinfanteri (antal, gruppstorlek, sannolikhet).
- _infantry: Inställningar för infanteripatruller (antal, gruppstorlek, sannolikhet).
- _LVeh: Inställningar för lätta fordon (antal, gruppstorlek, sannolikhet).
- _AVgrp: Inställningar för bepansrade fordon (antal, sannolikhet).
- _SVgrp: Inställningar för specialfordon (antal, sannolikhet).
- _CHGrp: Inställningar för helikoptergrupper (antal, gruppstorlek, sannolikhet).
- _settings: Övriga inställningar för EOS.

Important Notes:
- Det är viktigt att detta skript körs på servern, annars loggas ett felmeddelande.
- Markörnamn måste vara korrekt definierade för att skriptet ska fungera.

Potential Errors:
- Om JIP-markörerna inte är definierade loggas ett felmeddelande och skriptet avslutas.
- Dubbel deklaration av variabler kan leda till oväntade beteenden.

Returns:
- Inga specifika returer, enheter och patrullgrupper skapas och hanteras inom zonen.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_eos_launch.sqf] starts at %1", _timestamp];

// Kontrollera om koden körs på servern
if (!isServer) then {
    // Logga ett meddelande om koden inte körs på servern
    diag_log "EOS Launch: Denna kod måste köras på servern";
} else {
    // Deklarera och initialisera lokala variabler för att hantera olika grupper och deras sannolikheter
    private [
        "_HPpatrols",               // Antal huspatruller
        "_HPgroupProbability",      // Sannolikhet att skapa en huspatrullgrupp
        "_CHgroupArray",            // Array för helikoptergruppstorlekar
        "_LVgroupArray",            // Array för lätta fordon gruppstorlekar
        "_HPgroupArray",            // Array för huspatrullgruppstorlekar
        "_PAgroupArray",            // Array för infanteripatrullgruppstorlekar
        "_CHgroupSize",             // Storlek på helikoptergrupp
        "_CHGroups",                // Antal helikoptergrupper
        "_SVehGroups",              // Antal specialfordonsgrupper
        "_AVgroupSize",             // Storlek på bepansrade fordonsgrupper
        "_AVehGroups",              // Antal bepansrade fordonsgrupper
        "_LVehGroups",              // Antal lätta fordonsgrupper
        "_LVgroupSize",             // Storlek på lätta fordonsgrupper
        "_PAgroupSize",             // Storlek på infanteripatrullgrupper
        "_PApatrols",               // Antal infanteripatruller
        "_HPpatrols",               // Antal huspatruller (duplicerad variabel, kan behöva korrigeras)
        "_HPgroupSize"              // Storlek på huspatrullgrupper
    ];

	// Hämta JIP-markörer (Join-In-Progress) från första argumentet
	_JIPmkr = (_this select 0);

	// Hämta husinfanteri-inställningar från andra argumentet
	_HouseInfantry = (_this select 1);
	// Sätt antal huspatruller från husinfanteri-inställningarna
	_HPpatrols = _HouseInfantry select 0;
	// Sätt huspatrullgruppstorlek från husinfanteri-inställningarna
	_HPgroupSize = _HouseInfantry select 1;
	// Sätt sannolikheten för att skapa en huspatrullgrupp, standardvärde 100% om ej definierat
	_HPgroupProbability = if (count _HouseInfantry > 2) then { _HouseInfantry select 2 } else { 100 };

	// Hämta infanteri-inställningar från tredje argumentet
	_infantry = (_this select 2);
	// Sätt antal infanteripatruller från infanteri-inställningarna
	_PApatrols = _infantry select 0;
	// Sätt infanteripatrullgruppstorlek från infanteri-inställningarna
	_PAgroupSize = _infantry select 1;
	// Sätt sannolikheten för att skapa en infanteripatrullgrupp, standardvärde 100% om ej definierat
	_PAgroupProbability = if (count _infantry > 2) then { _infantry select 2 } else { 100 };

	// Hämta lätta fordons-inställningar från fjärde argumentet
	_LVeh = (_this select 3);
	// Sätt antal lätta fordonsgrupper från lätta fordons-inställningarna
	_LVehGroups = _LVeh select 0;
	// Sätt lätta fordonsgruppstorlek från lätta fordons-inställningarna
	_LVgroupSize = _LVeh select 1;
	// Sätt sannolikheten för att skapa en lätt fordonsgrupp, standardvärde 100% om ej definierat
	_LVgroupProbability = if (count _LVeh > 2) then { _LVeh select 2 } else { 100 };

	// Hämta bepansrade fordons-inställningar från femte argumentet
	_AVgrp = (_this select 4);
	// Sätt antal bepansrade fordonsgrupper från bepansrade fordons-inställningarna
	_AVehGroups = _AVgrp select 0;
	// Sätt sannolikheten för att skapa en bepansrad fordonsgrupp, standardvärde 100% om ej definierat
	_AVgroupProbability = if (count _AVgrp > 1) then { _AVgrp select 1 } else { 100 };

	// Hämta specialfordons-inställningar från sjätte argumentet
	_SVgrp = (_this select 5);
	// Sätt antal specialfordonsgrupper från specialfordons-inställningarna
	_SVehGroups = _SVgrp select 0;
	// Sätt sannolikheten för att skapa en specialfordonsgrupp, standardvärde 100% om ej definierat
	_SVgroupProbability = if (count _SVgrp > 1) then { _SVgrp select 1 } else { 100 };

	// Hämta helikoptergrupps-inställningar från sjunde argumentet
	_CHGrp = (_this select 6);
	// Sätt antal helikoptergrupper från helikoptergrupps-inställningarna
	_CHGroups = _CHGrp select 0;
	// Sätt helikoptergruppstorlek från helikoptergrupps-inställningarna
	_CHgroupSize = _CHGrp select 1;
	// Sätt sannolikheten för att skapa en helikoptergrupp, standardvärde 100% om ej definierat
	_CHgroupProbability = if (count _CHGrp > 2) then { _CHGrp select 2 } else { 100 };

	// Hämta generella inställningar från åttonde argumentet
	_settings = (_this select 7);

	// Kontrollera sannolikheten för att skapa en huspatrullgrupp
	if (_HPgroupProbability > floor random 100) then {
		// Tilldela gruppstorlek baserat på _HPgroupSize
		if (_HPgroupSize == 0) then { _HPgroupArray = [1,1] };
		if (_HPgroupSize == 1) then { _HPgroupArray = [2,4] };
		if (_HPgroupSize == 2) then { _HPgroupArray = [4,8] };
		if (_HPgroupSize == 3) then { _HPgroupArray = [8,12] };
		if (_HPgroupSize == 4) then { _HPgroupArray = [12,16] };
		if (_HPgroupSize == 5) then { _HPgroupArray = [16,20] };
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal huspatruller till 0 och standardgruppstorlek
		_HPpatrols = 0; 
		_HPgroupArray = [1,1]; 
	};

	// Kontrollera sannolikheten för att skapa en infanteripatrullgrupp
	if (_PAgroupProbability > floor random 100) then {	
		// Tilldela gruppstorlek baserat på _PAgroupSize
		if (_PAgroupSize == 0) then { _PAgroupArray = [1,1] };
		if (_PAgroupSize == 1) then { _PAgroupArray = [2,4] };
		if (_PAgroupSize == 2) then { _PAgroupArray = [4,8] };
		if (_PAgroupSize == 3) then { _PAgroupArray = [8,12] };
		if (_PAgroupSize == 4) then { _PAgroupArray = [12,16] };
		if (_PAgroupSize == 5) then { _PAgroupArray = [16,20] };
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal infanteripatruller till 0 och standardgruppstorlek
		_PApatrols = 0; 
		_PAgroupArray = [1,1]; 
	};

	// Kontrollera sannolikheten för att skapa en lätt fordonsgrupp
	if (_LVgroupProbability > floor random 100) then {	
		// Tilldela gruppstorlek baserat på _LVgroupSize
		if (_LVgroupSize == 0) then { _LVgroupArray = [0,0] };
		if (_LVgroupSize == 1) then { _LVgroupArray = [2,4] };
		if (_LVgroupSize == 2) then { _LVgroupArray = [4,8] };
		if (_LVgroupSize == 3) then { _LVgroupArray = [8,12] };
		if (_LVgroupSize == 4) then { _LVgroupArray = [12,16] };
		if (_LVgroupSize == 5) then { _LVgroupArray = [16,20] };
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal lätta fordonsgrupper till 0 och standardgruppstorlek
		_LVehGroups = 0; 
		_LVgroupArray = [0,0]; 
	};

	// Kontrollera sannolikheten för att skapa en bepansrad fordonsgrupp
	if (_AVgroupProbability > floor random 100) then {
		// Sätts här om fler detaljer behövs
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal bepansrade fordonsgrupper till 0
		_AVehGroups = 0; 
	};

	// Kontrollera sannolikheten för att skapa en specialfordonsgrupp
	if (_SVgroupProbability > floor random 100) then {
		// Sätts här om fler detaljer behövs
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal specialfordonsgrupper till 0
		_SVehGroups = 0; 
	};

	// Kontrollera sannolikheten för att skapa en helikoptergrupp
	if (_CHgroupProbability > floor random 100) then {
		// Tilldela gruppstorlek baserat på _CHgroupSize
		if (_CHgroupSize == 0) then { _CHgroupArray = [0,0] };
		if (_CHgroupSize == 1) then { _CHgroupArray = [2,4] };
		if (_CHgroupSize == 2) then { _CHgroupArray = [4,8] };
		if (_CHgroupSize == 3) then { _CHgroupArray = [8,12] };
		if (_CHgroupSize == 4) then { _CHgroupArray = [12,16] };
		if (_CHgroupSize == 5) then { _CHgroupArray = [16,20] };
	} else { 
		// Om sannolikheten inte uppfylls, sätt antal helikoptergrupper till 0 och standardgruppstorlek
		_CHGroups = 0; 
		_CHgroupArray = [0,0]; 
	};

	// Kontrollera om JIP-markörerna är definierade
	if (isNil "_JIPmkr") exitWith {
		// Logga ett felmeddelande om JIP-markörerna inte är definierade
		diag_log "EOS Launch ERROR: JIP Markers är odefinierade";
	};

	// Iterera över varje JIP-markör
	{
		// Hämta aktuella EOS-markörer från missionNamespace, eller skapa en tom lista om de inte finns
		_eosMarkers = missionNamespace getVariable ["EOSmarkers", []];
		if (isNil "_eosMarkers") then { _eosMarkers = [] };

		// Lägg till aktuell markör till listan över EOS-markörer
		_eosMarkers set [count _eosMarkers, _x];

		// Uppdatera missionNamespace med den nya listan av EOS-markörer
		missionNamespace setVariable ["EOSmarkers", _eosMarkers, true];

		// Starta EOS-kärnfunktionalitet för den aktuella markören
		null = [
			_x,                                        // Markörens namn
			[_HPpatrols, _HPgroupArray],               // Inställningar för huspatruller
			[_PApatrols, _PAgroupArray],               // Inställningar för infanteripatruller
			[_LVehGroups, _LVgroupArray],              // Inställningar för lätta fordonsgrupper
			[_AVehGroups, _SVehGroups, _CHGroups, _CHgroupArray], // Inställningar för bepansrade fordon, specialfordon och helikoptrar
			_settings                                 // Övriga inställningar
		] spawn compile preprocessFileLineNumbers EOS_core_path;

	} forEach _JIPmkr;
};