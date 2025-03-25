// fn_escort.sqf
params ["_target", "_caller", "_actionId", "_arguments"];

localPlayer = _caller;
_unit = _target;
_toggle = _arguments select 0;
_toggleHoldAction = _arguments select 1;
_toggleOn = _arguments select 2;

// Track the unit being escorted
localPlayer setVariable ["_trackedUnit", _unit];

// Function to handle escorting the AI vehicle
DONK_fnc_escortAIVehicle = {
    params["_vehicle", ["_toggleOn", true]];
    localPlayer setVariable ["_vehicleToggle", _toggleOn];

    if (vehicle localPlayer isEqualTo localPlayer && _toggleOn) then {
        _trackedUnit = localPlayer getVariable "_trackedUnit";
        unassignVehicle _trackedUnit;
        moveOut _trackedUnit;
        [_vehicle, false] spawn DONK_fnc_holdActionVehicle;
    };
};

// Function to manage hold action for the vehicle
DONK_fnc_holdActionVehicle = {
    params["_vehicle", ["_toggleHoldAction", true], ["_codeOnEnd", {}], ["_toggleOn", true]];

    if (!_toggleHoldAction) exitWith {
        [_vehicle, false] call DONK_fnc_escortAIVehicle;
        _vehicle setVariable ["_idHoldAction", nil];
        localPlayer setVariable ["_vehicleToggle", nil];
        true
    };

    _idHoldAction = [_vehicle, "true", "true", DONK_fnc_escortAIVehicle, DONK_fnc_holdActionVehicle, _toggleOn, {}, false];
    _vehicle setVariable ["_idHoldAction", _idHoldAction];
    localPlayer setVariable ["_vehicleToggle", _toggleOn];
};

// Exit if not toggled on
if (!_toggleOn) exitWith {
    doStop _unit;
    localPlayer removeEventHandler ["GetInMan", localPlayer getVariable ["_idGetInMan", -1]];
    localPlayer removeEventHandler ["GetOutMan", localPlayer getVariable ["_idGetOutMan", -1]];
    localPlayer setVariable ["_idGetInMan", nil];
    localPlayer setVariable ["_idGetOutMan", nil];
    localPlayer setVariable ["_npcIsFollowing", nil];
};

// Exit if hold action is not toggled
if (!_toggleHoldAction) exitWith {
    [_unit, false] call DONK_fnc_escortAIVehicle;
};

// Event handler for unit deletion
private _idDeletedHandler = _unit addEventHandler ["Deleted", {
    params["_unit"];
    private _getInFired = _unit getVariable ["_getInFired", 0];
    if (_getInFired > 0 && (time - _getInFired) <= 5) exitWith {};

    _unit setVariable ["_getInFired", nil];
    [_unit, false] call BIS_fnc_escortAIHoldAction;

    [vehicleVarName _unit] spawn {
        params["_unitName"];
        sleep 2;
        private _unit = objNull;
        waitUntil { sleep 0.5; _unit = (missionNamespace getVariable [_unitName, objNull]); !isNull _unit };
        [_unit] call BIS_fnc_escortAIHoldAction;
    };
}];

_unit setVariable ["_idDeletedHandler", _idDeletedHandler];

// Clear existing waypoints and set unit behavior
{ deleteWaypoint _x } forEach waypoints group _unit;
_unit setSpeedMode "FULL";
_unit setSkill 1;
_unit setCombatMode "BLUE";
_unit setBehaviour "CARELESS";
_unit setUnloadInCombat [false, false];
_unit doFollow _unit;
_unit enableSimulation true;
_unit switchMove "";
_unit disableAI "RADIOPROTOCOL";
localPlayer setVariable ["_npcIsFollowing", true];

// Spawn a loop to manage following behavior
[_unit] spawn {
    params["_unit"];
    while { (localPlayer getVariable ["_npcIsFollowing", false]) } do {
        if (vehicle localPlayer isEqualTo localPlayer) then {
            if (localPlayer distance _unit >= 3) then {
                _unit doMove (getPos vehicle localPlayer);
            } else {
                _unit lookAt localPlayer;
                doStop _unit;
                _unit doFollow _unit;
            };
        };
        sleep 0.4;
    };
};

// Add event handler for getting in the vehicle
if ((localPlayer getVariable ["_idGetInMan", -1]) isEqualTo -1) then {
    _idGetInMan = localPlayer addEventHandler ["GetInMan", {
        params["_unit", "_position", "_vehicle"];
        _trackedUnit = localPlayer getVariable "_trackedUnit";
        
        if (!isNull _trackedUnit && alive _trackedUnit) then { // Check if the unit is alive
            _trackedUnit setVariable ["_getInFired", time];
            _trackedUnit assignAsCargo _vehicle;
            _trackedUnit moveInCargo _vehicle;

            if ((_vehicle getVariable ["_idHoldAction", -1]) isEqualTo -1) then {
                [_vehicle, true, {}, !(localPlayer getVariable ["_vehicleToggle", true])] call DONK_fnc_holdActionVehicle;
            };
        };
    }];
    localPlayer setVariable ["_idGetInMan", _idGetInMan];
};

// Add event handler for getting out of the vehicle
if ((localPlayer getVariable ["_idGetOutMan", -1]) isEqualTo -1) then {
    _idGetOutMan = localPlayer addEventHandler ["GetOutMan", {
        params["_unit", "_position", "_vehicle"];
        _trackedUnit = localPlayer getVariable "_trackedUnit";
        
        if (!isNull _trackedUnit && alive _trackedUnit) then { // Check if the unit is alive
            unassignVehicle _trackedUnit;
            moveOut _trackedUnit;
            [_vehicle, false] call DONK_fnc_holdActionVehicle;
        };
    }];
    localPlayer setVariable ["_idGetOutMan", _idGetOutMan];
};