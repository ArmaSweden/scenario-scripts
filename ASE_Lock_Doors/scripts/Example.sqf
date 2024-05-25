//LOCK DOORS.
[_markerName,100] call fnc_lock_doors; //Alla dörrar inom 100 meter från markören _markerName stängs och låses.

// Eller i onActivation-fältet på en trigger.
[_this, 100] call fnc_lock_doors;

