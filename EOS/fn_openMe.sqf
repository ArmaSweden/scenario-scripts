/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
EOS, eller Enemy Occupation System, är ett skriptpaket designat för att generera och hantera fiendeenheter och deras beteenden inom Arma 3-miljön. 
Det är anpassningsbart för olika svårighetsgrader och fraktioner, vilket möjliggör dynamiska och varierade upplevelser för spelarna. 
Systemet hanterar allt från spawna enheter till att sätta AI-färdigheter och loggar relevant information för debugging.

Syftet med EOS är att automatisera skapandet och hanteringen av fiendeenheter baserat på fördefinierade regler och parametrar. 
Detta inkluderar att generera patruller, fordon, helikoptrar och andra enheter, sätta deras färdigheter, hantera deras beteende och interaktioner, samt spåra och logga deras aktiviteter.

Variables:
- difficultyLevel: Svårighetsgrad inställd i missionNamespace.
- VictoryColor, hostileColor, bastionColor: Färger för markörer baserat på zonstatus.

Remarks:
Skriptet sätter svårighetsgrad, kompilerar och exekverar AI-färdigheter och andra funktioner, samt definierar färger och inställningar för EOS.

Important Notes:
- Svårighetsgrad och färger måste vara korrekt definierade i missionNamespace.
- Viktiga funktioner kompileras och sparas för global åtkomst.
- Beroende av LAMBS 

Potential Errors:
- Om sökvägar till funktionerna inte är korrekta kan det leda till fel vid kompilerings- och exekveringstid.

Returns:
- Inga specifika returer, EOS-systemet initialiseras och viktiga funktioner kompileras.
*/

private _timeStamp = diag_tickTime;
diag_log format ["[EOS] (fn_openMe) INFO: Reading settings from file at %1", _timestamp];

// Loggar starten av initialisering av EOS systemet i diagnosloggen
diag_log "Startar Initialisering av EOS";

// Ställ in svårighetsgraden här
private _difficulty = 5; // Exempel: svårighetsgrad "Super AI"

// Sätt svårighetsgraden i missionNamespace
missionNamespace setVariable ["difficultyLevel", _difficulty];

//Path helpers
EOS_path_spawn = "EOS\core\fn_spawn_fnc.sqf";
EOS_path_EOSMarkers = "EOS\functions\fn_markers.sqf";
EOS_Spawn_Path = "EOS\core\fn_eos_launch.sqf";
EOS_Bastion_Spawn_Path = "EOS\core\fn_b_launch.sqf";
EOS_core_path = "EOS\core\fn_eos_core.sqf";
EOS_Bastion_core_path = "EOS\core\fn_b_core.sqf";
EOS_AI_Skills_path = "EOS\fn_AI_Skills.sqf";

eos_fnc_spawnvehicle_path = "EOS\functions\fn_spawnVehicle.sqf";
eos_fnc_grouphandlers_path = "EOS\functions\fn_setSkill.sqf";
eos_fnc_findsafepos_path = "EOS\functions\fn_findSafePos.sqf";
eos_fnc_spawngroup_path = "EOS\functions\fn_infantry.sqf";
eos_fnc_setcargo_path = "EOS\functions\fn_cargo.sqf";
eos_fnc_pos_path = "EOS\functions\fn_pos.sqf";
eos_fnc_transportUnload_path = "EOS\functions\fn_transportUnload.sqf";
eos_fnc_getunitpool_path = "EOS\fn_unitPools.sqf";
eos_fnc_killCounter_path = "EOS\functions\fn_killCounter.sqf";


// Kompilera och exekvera AI-färdigheter från en specifik fil
call compile preprocessfilelinenumbers EOS_AI_Skills_path;

// Kompilera och spara EOS_Spawn-funktionen om den inte redan finns, annars logga att den redan är laddad
if (isNil "EOS_Spawn") then {
    EOS_Spawn = compileFinal preprocessFileLineNumbers EOS_Spawn_Path;
    diag_log "EOS core functionalities compiled.";
} else {
    diag_log "EOS core functionalities already loaded.";
};

// Kompilera och spara Bastion_Spawn-funktionen om den inte redan finns, annars logga att den redan är laddad
if (isNil "Bastion_Spawn") then {
    Bastion_Spawn = compileFinal preprocessFileLineNumbers EOS_Bastion_Spawn_Path;
    diag_log "Bastion functionalities compiled.";
} else {
    diag_log "Bastion functionalities already loaded.";
};

// Kontrollerar om filen för spawnfunktionen finns, om så är fallet kompilerar och exekverar den
if (fileExists EOS_path_spawn) then {
    call compile preprocessFileLineNumbers EOS_path_spawn;
    diag_log format ["Script %1 have been loaded", EOS_path_spawn];
} else {
    diag_log format ["Script %1 have not been loaded, check the file path and availability", EOS_path_spawn];
};

// Lägger till en hanterare för händelsen när spelare ansluter för att ladda markörfunktioner, om filen finns
if (fileExists EOS_path_EOSMarkers) then {
    addMissionEventHandler ["PlayerConnected", {
        call compile preprocessFileLineNumbers EOS_path_EOSMarkers;
        diag_log ["Script EOS Markers have been loaded"];
    }];
} else {
    diag_log ["Script EOS Markers have not been loaded, check the file path and availability"];
};

// Definition av standardvärden och grupperingsstorlekar för EOS
/* EOS 1.98
GROUP SIZES
 0 = 1
 1 = 2,4
 2 = 4,8
 3 = 8,12
 4 = 12,16
 5 = 16,20
*/

// Definierar färger och inställningar för EOS och lagrar dem i missionNamespace
VictoryColor="colorGreen";    // Färg för markör efter avslutad uppgift
hostileColor="colorRed";      // Standardfärg när fiender är aktiva
bastionColor="colorOrange";   // Färg för Bastion-markören
EOS_DAMAGE_MULTIPLIER=1;      // Skademultiplikator, 1 är standard
EOS_KILLCOUNTER=true;         // Aktiverar räkning av dödade enheter

// Spara inställningarna i missionNamespace för global åtkomst
missionNamespace setVariable ["EOS_Spawn", EOS_Spawn];
missionNamespace setVariable ["Bastion_Spawn", Bastion_Spawn];
missionNamespace setVariable ["VictoryColor", VictoryColor];
missionNamespace setVariable ["hostileColor", hostileColor];
missionNamespace setVariable ["bastionColor", bastionColor];
missionNamespace setVariable ["EOS_DAMAGE_MULTIPLIER", EOS_DAMAGE_MULTIPLIER];
missionNamespace setVariable ["EOS_KILLCOUNTER", EOS_KILLCOUNTER];