params ["_doBackup"];
private _queryName = "resetSectors";

private _void = [_queryName] call GCS_fnc_database_executeQuery;