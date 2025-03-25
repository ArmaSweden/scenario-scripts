private _queryName = "deleteSectorsBackups";
private _return = "";
_isSuccess = false;

_return = ([_queryName] call LB_fnc_database_executeQuery) select 0;
if (_return isEqualTo 1) then { _isSuccess = true; } else { _isSuccess = false; };

_isSuccess