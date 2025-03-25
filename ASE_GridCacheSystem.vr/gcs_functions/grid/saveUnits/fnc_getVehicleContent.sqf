params["_veh"];
[(getMagazineCargo _veh) call GCS_fnc_tools_arrayMerge,
 (getWeaponCargo _veh) call GCS_fnc_tools_arrayMerge,
 (getBackpackCargo _veh) call GCS_fnc_tools_arrayMerge ,
 (getItemCargo _veh) call GCS_fnc_tools_arrayMerge]
