// functions\config\fn_initSitting.sqf
/*
Author: Emek1501

Description:
Initializes the sitting system by processing chair configurations from the mission config file
and setting up the necessary actions for each valid chair type. This function runs once at
mission start through the PostInit event handler.

Variables:
- SIT_initialized: Global boolean to prevent multiple initializations
- SIT_initializedClasses: Global array containing all valid chair classnames
- _chairTypes: Local array of config classes from CfgSitting >> ChairTypes
- _class: Local string containing the current chair classname being processed

Parameters:
None

Returns:
None

Important:
- Must be called only once per mission
- Requires valid CfgSitting configuration in description.ext
- Chair classes must have canSit parameter defined

Notes:
- Function exits if already initialized (prevents duplicate initialization)
- Only processes chairs with canSit = 1
- Automatically adds ACE interactions to all valid chair types
- Broadcasts initialized classes to all clients

Potential Errors:
- Missing or invalid CfgSitting configuration
- Incorrect function paths in description.ext
- Network synchronization issues if publicVariable fails

Example:
// Called through PostInit event handler
[] call SIT_fnc_initSitting;

*/

if (!isNil "SIT_initialized") exitWith {};
SIT_initialized = true;

SIT_initializedClasses = [];

private _chairTypes = "true" configClasses (missionConfigFile >> "CfgSitting" >> "ChairTypes");
{
    private _class = configName _x;
    if (getNumber (_x >> "canSit") == 1) then {
        SIT_initializedClasses pushBack _class;
        [_class] call SIT_fnc_addSitActions;
    };
} forEach _chairTypes;

publicVariable "SIT_initializedClasses";