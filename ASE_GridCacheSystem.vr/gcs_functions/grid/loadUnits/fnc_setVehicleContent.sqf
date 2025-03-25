params["_veh", "_array"];
clearMagazineCargoGlobal _veh;
clearWeaponCargoGlobal _veh;
clearBackpackCargoGlobal _veh;
clearItemCargoGlobal _veh;
{
	_veh addMagazineCargoGlobal _x;
} forEach (_array select 0);
{
	_veh addWeaponCargoGlobal _x;
} forEach (_array select 1);
{
	_veh addBackpackCargoGlobal _x;
} forEach (_array select 2);
{
	_veh addItemCargoGlobal _x;
} forEach (_array select 3);

