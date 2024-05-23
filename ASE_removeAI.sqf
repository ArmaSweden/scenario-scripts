/*
Author: Emek1501 [ASE]

Description:
Detta skript hanterar borttagning av alla AI-enheter som lagrats i en global variabel inom uppdragets namnrymd. 
Det itererar genom arrayen av AI-enheter, loggar borttagningsprocessen, raderar varje enhet från spelet och uppdaterar slutligen den globala variabeln för att reflektera att AI-enheterna har tagits bort.

Variables:
- _AIUnitsArray_1: En array som håller referenser till AI-enheterna som skapats under uppdraget. 
Om variabeln inte finns, returneras en tom array.

Remarks:
Detta skript är avsett att användas för att rensa bort AI-enheter som tidigare skapats och lagrats i uppdragets namnrymd. 
Det säkerställer att alla enheter raderas korrekt och att den globala variabeln uppdateras för att återspegla förändringarna.

Parameter(s):
Inga

Important Notes:
- Den globala variabeln "AIUnitsArray_1" måste finnas och innehålla referenser till de AI-enheter som skapats tidigare i uppdraget. Om denna variabel inte finns eller är tom, kommer skriptet helt enkelt att returnera utan att utföra några borttagningar.
- Skriptet använder kommandot deleteVehicle för att ta bort varje enhet från spelet.

Potential Errors:
- Om den globala variabeln "AIUnitsArray_1" inte finns eller inte är korrekt inställd, kommer skriptet inte att ta bort några enheter.
- Om någon av enheterna i arrayen redan har tagits bort eller är ogiltiga, kan deleteVehicle-kommandot logga en error.

Returns:
Inga

Example:
[] call compile preprocessFileLineNumbers "ASE_removeAI.sqf";
*/


// Hämtar listan över AI-enheter lagrad i missionsnamnsutrymmet. Om variabeln inte existerar, returneras en tom array.
private _AIUnitsArray_1 = missionNamespace getVariable ["AIUnitsArray_1", []];

// Loggar ett meddelande som indikerar att borttagningsprocessen för AI-enheter har startat.
diag_log "Startar borttagning av AI-enheter...";

// Itererar genom varje enhet i listan av AI-enheter.
{
    // Loggar varje enhet som ska tas bort.
    diag_log format ["Tar bort AI-enhet: %1", _x];
    
    // Tar bort enheten från spelet.
    deleteVehicle _x;
} forEach _AIUnitsArray_1;

// Uppdaterar variabeln i missionsnamnsutrymmet till en tom array för att indikera att alla enheter har tagits bort.
missionNamespace setVariable ["AIUnitsArray_1", []];

// Loggar ett meddelande som bekräftar att alla skapade AI-enheter har tagits bort.
diag_log "Alla skapade AI-enheter har tagits bort.";