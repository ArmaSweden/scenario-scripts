/*
    Author: Emek1501 [ASE]

    Description:
    Funktion för att kontinuerligt kontrollera avståndet mellan spelaren och ett specifikt objekt och utföra en åtgärd om spelaren befinner sig inom ett visst avstånd.

    Parameter(s):
    0: OBJECT - Spelaren
    1: OBJECT - Objektet
    2: NUMBER - Avståndsgräns i meter (använd kvadrattal)

    Returns:
    None

    Example:
    [player, targetObject, 4] spawn compile preprocessFileLineNumbers "ASE_checkDistance.sqf";
*/

private _player = _this select 0;
private _targetObject = _this select 1;
private _distanceLimit = _this select 2;

while {true} do {
    // Kontrollera om spelaren är inom angivet avstånd från objektet
    if ((player distanceSqr _targetObject) < _distanceLimit) then {
        diag_log format ["%1 is within %2 meters of %3", name _player, _distanceLimit, _targetObject];
    } else {
        diag_log "[ERROR] (checkDistance) INFO: No player alive";
    };
    sleep 0.1; // Minimera belastningen genom att lägga in en kort fördröjning
};