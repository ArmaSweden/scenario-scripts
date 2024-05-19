/*
Version: 1.0.0 [2024-05-19]

Author: 
Remake by Emek1501 [ASE]

Original by bangabob
https://forums.bohemia.net/forums/topic/144150-enemy-occupation-system-eos/

Description:
Hantera markörer för EOS-systemet, inklusive aktivering, deaktivering och uppdatering av markörers status och färger.

Variables:
- _timestamp: Tidsstämpel vid start av skriptet.
- _mkr: Markeringsnamn som ska uppdateras.
- _color: Färg som markören ska sättas till.
- _alpha: Alfa-nivå för markörens synlighet.

Remarks:
Skriptet uppdaterar markörers status och färger baserat på zonens status, och hanterar aktivering och deaktivering av markörer.

Parameter(s):
- _mkr: Markeringsnamn som ska uppdateras.
- _color: Färg som markören ska sättas till.
- _alpha: Alfa-nivå för markörens synlighet.

Important Notes:
- Markeringsnamn måste vara korrekt definierade för att uppdateringar ska ske korrekt.
- Färger och alfa-nivåer måste vara korrekt inställda för att undvika visuella fel.

Potential Errors:
- Felaktigt definierade markörnamn kan leda till att markörer inte uppdateras korrekt.
- Om färger eller alfa-nivåer inte är korrekt definierade kan det leda till visuella fel eller att markörer inte syns.

Returns:
- Inga specifika returer, markörer uppdateras direkt.
*/


private _timeStamp = diag_tickTime;

diag_log format ["[fn_markers.sqf] starts at %1", _timestamp];

// Antag att EOS-markörerna lagras i missionNamespace
_eosMarkers = missionNamespace getVariable ["EOSmarkers", []];

{
    // Detta antar att du vill uppdatera markörernas egenskaper dynamiskt
    // Annars, om det inte finns behov av att sätta alpha eller färg på nytt, kan dessa rader tas bort
    _x setMarkerAlpha (markerAlpha _x);
    _x setMarkerColor (getMarkerColor _x);
} forEach _eosMarkers;
