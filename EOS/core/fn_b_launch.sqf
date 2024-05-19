/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Initierar och hanterar bastionszoner, skapar enheter och fordon inom dessa zoner samt hanterar deras beteenden och uppdrag.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _mkr: Markeringsposition som representerar bastionszonen.
- _difficulty: Svårighetsgrad som används för att justera enheternas färdigheter.
- _infantry, _LVeh, _AVeh, _SVeh: Konfigurationer för olika typer av enheter.
- _settings: Inställningar för bastionszonen.
- _waves: Antal vågor av förstärkningar.

Remarks:
Detta skript ansvarar för att skapa och konfigurera enheter inom en bastionszon, inklusive infanteri, lätta fordon, bepansrade fordon och helikoptrar. Det hanterar också uppdrag och uppdateringar för zonens status.

Parameter(s):
- _mkr: Markeringsposition som representerar bastionszonen.
- _infantry: Array som innehåller antal infanteripatruller och deras storlek.
- _LVeh: Array som innehåller antal lätta fordonsgrupper och deras storlek.
- _AVeh: Array som innehåller antal bepansrade fordonsgrupper.
- _SVeh: Array som innehåller antal helikoptergrupper och deras storlek.
- _settings: Array med inställningar för EOS (fraktion, markörens alfa, sida, höjdbegränsning, debug).
- _basSettings: Array med basinställningar (paus, vågor, timeout, EOS-zon, tipsmeddelanden).
- _initialLaunch: Boolean som indikerar om det är en initial start.

Important Notes:
- Skriptet måste köras på servern.
- Markeringspositionen måste vara korrekt definierad för att skapa enheter i rätt område.
- Om höjdbegränsning är aktiverad, kontrolleras enheternas höjd innan aktivering.

Potential Errors:
- Felaktigt definierade inställningar kan leda till att enheter inte skapas korrekt.
- Om markeringspositionen inte är korrekt definierad kan det leda till att enheter skapas utanför önskat område.

Returns:
- Inga specifika returer, enheter och fordon skapas och hanteras inom bastionszonen.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_b_launch.sqf] starts at %1", _timestamp];

// Kontrollera om koden körs på servern
if (!isServer) then {
    diag_log "EOS b_Launch: Denna kod måste köras på servern";
} else {
    // Deklarera variabler för att hålla information om grupper och patruller
    private [
        "_CHgroupArray",  // Array för helikoptergrupper
        "_LVgroupArray",  // Array för lätta fordonsgrupper
        "_PAgroupArray",  // Array för patrullgrupper
        "_CHGroups",      // Antal helikoptergrupper
        "_AVehGroups",    // Antal bepansrade fordonsgrupper
        "_LVehGroups",    // Antal lätta fordonsgrupper
        "_PApatrols"      // Antal patruller
    ];

	// Hämta data från inputparametrarna
    _JIPmkr = (_this select 0);           // Markörer för spelare som ansluter sig senare (JIP - Join In Progress)
    _infantry = (_this select 1);          // Data för infanterigrupper
    _PApatrols = _infantry select 0;       // Antal patruller
    _PAgroupSize = _infantry select 1;     // Storlek på patrullgrupper
    _LVeh = (_this select 2);              // Data för lätta fordon
    _LVehGroups = _LVeh select 0;          // Antal lätta fordonsgrupper
    _LVgroupSize = _LVeh select 1;         // Storlek på lätta fordonsgrupper
    _AVeh = (_this select 3);              // Data för bepansrade fordon
    _AVehGroups = _AVeh select 0;          // Antal bepansrade fordonsgrupper
    _SVeh = (_this select 4);              // Data för helikoptrar
    _CHGroups = _SVeh select 0;            // Antal helikoptergrupper
    _CHgroupSize = _SVeh select 1;         // Storlek på helikoptergrupper
    _settings = (_this select 5);          // Inställningar för EOS
    _basSettings = (_this select 6);       // Basinställningar för EOS

	// Definiera storlekar på patrullgrupper baserat på _PAgroupSize
    if (_PAgroupSize == 0) then { _PAgroupArray = [1, 1] };   // En liten patrull
    if (_PAgroupSize == 1) then { _PAgroupArray = [2, 4] };   // Liten till medelstor patrull
    if (_PAgroupSize == 2) then { _PAgroupArray = [4, 8] };   // Medelstor patrull
    if (_PAgroupSize == 3) then { _PAgroupArray = [8, 12] };  // Stor patrull
    if (_PAgroupSize == 4) then { _PAgroupArray = [12, 16] }; // Mycket stor patrull
    if (_PAgroupSize == 5) then { _PAgroupArray = [16, 20] }; // Extremt stor patrull

	// Definiera storlekar på lätta fordonsgrupper baserat på _LVgroupSize
    if (_LVgroupSize == 0) then { _LVgroupArray = [1, 1] };   // En liten fordonsgrupp
    if (_LVgroupSize == 1) then { _LVgroupArray = [2, 4] };   // Liten till medelstor fordonsgrupp
    if (_LVgroupSize == 2) then { _LVgroupArray = [4, 8] };   // Medelstor fordonsgrupp
    if (_LVgroupSize == 3) then { _LVgroupArray = [8, 12] };  // Stor fordonsgrupp
    if (_LVgroupSize == 4) then { _LVgroupArray = [12, 16] }; // Mycket stor fordonsgrupp
    if (_LVgroupSize == 5) then { _LVgroupArray = [16, 20] }; // Extremt stor fordonsgrupp

	// Definiera storlekar på helikoptergrupper baserat på _CHgroupSize
    if (_CHgroupSize == 0) then { _CHgroupArray = [0, 0] };   // Ingen helikoptergrupp
    if (_CHgroupSize == 1) then { _CHgroupArray = [2, 4] };   // Liten helikoptergrupp
    if (_CHgroupSize == 2) then { _CHgroupArray = [4, 8] };   // Medelstor helikoptergrupp
    if (_CHgroupSize == 3) then { _CHgroupArray = [8, 12] };  // Stor helikoptergrupp
    if (_CHgroupSize == 4) then { _CHgroupArray = [12, 16] }; // Mycket stor helikoptergrupp
    if (_CHgroupSize == 5) then { _CHgroupArray = [16, 20] }; // Extremt stor helikoptergrupp

	    {
        // Hämta befintliga EOS-markörer från missionNamespace
        _eosMarkers = missionNamespace getVariable ["EOSmarkers", []];
        
        // Om inga EOS-markörer finns, initiera som tom array
        if (isNil "_eosMarkers") then { _eosMarkers = [] };
        
        // Lägg till den aktuella markören till EOS-markörerna
        _eosMarkers set [count _eosMarkers, _x];
        
        // Sätt variabeln EOSmarkers i missionNamespace till den uppdaterade listan
        missionNamespace setVariable ["EOSmarkers", _eosMarkers, true];
        
        // Starta EOS-funktionen för varje JIP-markör
        null = [
            _x,                                  // Markör
            [_PApatrols, _PAgroupArray],         // Patruller och deras storlekar
            [_LVehGroups, _LVgroupArray],        // Lätta fordon och deras storlekar
            [_AVehGroups],                       // Bepansrade fordon
            [_CHGroups, _CHgroupArray],          // Helikoptrar och deras storlekar
            _settings,                           // Inställningar för EOS
            _basSettings                         // Basinställningar för EOS
        ] spawn compile preprocessFileLineNumbers EOS_Bastion_core_path;
    } forEach _JIPmkr;                            // För varje JIP-markör
};