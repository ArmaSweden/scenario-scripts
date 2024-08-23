fnc_lock_doors = {
    _markerName = _this select 0;
    _range = _this select 1;
    _pos = getMarkerPos _markerName;
    _houses = nearestTerrainObjects [_pos, ["house", "building"], _range];

    {
        // Get the type of the current house
        private _houseType = typeOf _x;

        // Retrieve the number of doors for the current house
        private _doorsCount = getNumber (configFile >> "CfgVehicles" >> _houseType >> "numberOfDoors");

        // Only proceed if the house has doors
        if (_doorsCount > 0) then {
            for "_i" from 1 to _doorsCount do {
                private _var = format ["bis_disabled_Door_%1", _i];
                private _anim = format ["Door_%1_rot", _i];
                _x animate [_anim, 0]; // Lock the door
                _x setVariable [_var, 1, true]; // Set the door as locked
            };
        };
    } forEach _houses;
};
