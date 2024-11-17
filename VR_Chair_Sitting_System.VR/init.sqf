
if (hasInterface) then {
    player addAction ["Debug Chair Actions", {
        private _chairs = nearestObjects [player, ["Land_DeskChair_01_black_F"], 50];
        if (count _chairs > 0) then {
            private _chair = _chairs select 0;
            private _actions = _chair getVariable ["ace_interact_menu_actions", []];
            
            // Try to add action directly to the chair
            private _action = [
                "SIT_Debug",
                "Debug Sit",
                "",
                {hint "Debug action worked!"},
                {true}
            ] call ace_interact_menu_fnc_createAction;
            
            [_chair, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            
            diag_log format [
                "Chair Debug Info:
                Chair: %1
                Chair Type: %2
                Distance: %3
                Local: %4
                Actions: %5
                ACE Actions: %6
                All Variables: %7",
                _chair,
                typeOf _chair,
                player distance _chair,
                local _chair,
                _actions,
                _chair getVariable ["ace_interact_menu_actions", []],
                allVariables _chair
            ];
        };
    }];
};