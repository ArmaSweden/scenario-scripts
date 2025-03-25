private _queryName = "hasSectors";
_queryResult = 0;
_return = false;

_queryResult = ([_queryName] call GCS_fnc_database_executeQuery) select 0;
if ((_queryResult isEqualType 0) && (_queryResult > 0)) then { _return = true; } else { _return = false; };

_return