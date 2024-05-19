/*
    Author: Emek1501

    Description:
    Detta skript hanterar en mobil återupplivningslogik. Om spelaren är död och ett specifikt fordon inte är tillgängligt, kommer det att skapas och spelaren flyttas in i det.

    Variables:
    _timeStamp - Tidsstämpel när skriptet startar, används för loggning.
    _units - En array som innehåller enheterna som ska flyttas in i fordonet (i detta fall endast spelaren).
    _vehicle - Det specifika medicinska fordonet som används för återupplivning.
    _success - En boolean som indikerar om enheterna lyckades flyttas in i fordonet.
    _freeCargoSpace - Antalet lediga platser i fordonet.
    _unitsNotInTargetVehicle - En array av enheter som ännu inte är i fordonet.
    _unitsCount - Antalet enheter som inte är i fordonet.

	Parameters:
	"respawn_west" - Markörens namn
	medVic - Variabelnamnet på det specifika fordonet

    Important Notes:
    - Koden kontrollerar om den körs på en server. Om inte, avslutas skriptet.
    - Skriptet skapar ett nytt medicinskt fordon om det inte finns något tillgängligt och flyttar spelaren till det.
    - Kontrollera att "medVic" och "respawn_west" är korrekt definierade i ditt uppdrag.

    Potential Errors:
    - Om "medVic" inte är korrekt definierat kan det orsaka fel när man försöker radera eller skapa fordonet.
    - Om spelaren inte är korrekt definierad kan det orsaka fel vid kontroller av spelarens skada eller flyttning till fordonet.
*/

// Sparar nuvarande tid för loggning
private _timeStamp = diag_tickTime;
diag_log format ["[PG] (fn_mobileRespawn) INFO: Reading settings from file at %1", _timeStamp];

// Kontrollera om skriptet körs på en server
if (!isServer) then {
    diag_log "[mobileRespawn] (message) INFO: Not running on a server";
} else {
    // Om det är en server, starta ett nytt skript som körs parallellt
    [] spawn {
        // Kontrollera om det medicinska fordonet är förstört eller inte finns
        if !(alive medVic) then {
            diag_log format ["[ERROR] Vehicle %1 is not available", medVic];
            // Ta bort det gamla fordonet om det finns kvar
            deleteVehicle medVic;

            // Skapa ett nytt medicinskt fordon vid markerad position
            medVic = "typeOfYourVehicle" createVehicle getMarkerPos "respawn_west";
        } else {
            // Vänta tills fordonet inte längre är null (har skapats)
            waitUntil {!isNull medVic};
            // Kontrollera om spelaren är död (skadad till 100%)
            if (damage player == 1) then {
                // Definiera enheterna som ska flyttas (endast spelaren i detta fall)
                private _units = [player];
                private _vehicle = medVic;

                // Initialisera variabler för att spåra om flytten lyckades och ledigt utrymme i fordonet
                private _success = false;
                private _freeCargoSpace = {(_x select 0) isEqualTo objNull} count fullCrew [_vehicle, "", true];
                private _unitsNotInTargetVehicle = _units select {!(_x in _vehicle)};
                private _unitsCount = count _unitsNotInTargetVehicle;

                // Kontrollera om det finns tillräckligt med utrymme i fordonet för alla enheter
                if (_unitsCount <= _freeCargoSpace) then {
                    // Flytta varje enhet till fordonet
                    {
                        _x moveInAny _vehicle;
                    } forEach _unitsNotInTargetVehicle;
                    _success = true;
                } else {
                    diag_log "[mobileRespawn] (message) INFO: Not enough space in the vehicle for all units";
                };

                _success;
            };
            // Uppdatera markörpositionen till fordonets position
            "respawn_west" setMarkerPos getPos medVic;
            // Vänta i 15 sekunder innan nästa kontroll
            uiSleep 15;
        };
    };
};
