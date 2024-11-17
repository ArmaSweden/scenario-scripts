// functions\sitting\fn_getRandomAnimation.sqf
/*
Author: Emek1501

Description:
Returns a random sitting animation from a predefined list of available chair animations.
Includes various idle and movement animations for different chair types and positions.

Variables:
- _animations: Array of available sitting animation classnames

Parameters:
None

Returns:
STRING - Random animation classname from the predefined list

Important:
- Contains 24 different animations divided into categories:
 * ChairA (standard sitting)
 * ChairB (relaxed sitting)
 * ChairC (formal sitting)
 * ChairUA/UB/UC (urban variations)
- Each category includes:
 * 3 idle animations
 * 1 movement animation

Notes:
- Uses selectRandom command for true random selection
- All animations are vanilla Arma 3 animations
- Animations include both static and dynamic poses
- No input validation required as function has no parameters

Potential Errors:
- Animation may not fit all chair types perfectly
- Some animations might not be available in certain game versions
- Custom animation mods might conflict with these animations

Example:
// Get a random sitting animation
private _randomAnim = [] call SIT_fnc_getRandomAnimation;

*/

private _animations = [
    "HubSittingChairA_idle1",
    "HubSittingChairA_idle2",
    "HubSittingChairA_idle3",
    "HubSittingChairA_move1",
    "HubSittingChairB_idle1",
    "HubSittingChairB_idle2",
    "HubSittingChairB_idle3",
    "HubSittingChairB_move1",
    "HubSittingChairC_idle1",
    "HubSittingChairC_idle2",
    "HubSittingChairC_idle3",
    "HubSittingChairC_move1",
    "HubSittingChairUA_idle1",
    "HubSittingChairUA_idle2",
    "HubSittingChairUA_idle3",
    "HubSittingChairUA_move1",
    "HubSittingChairUB_idle1",
    "HubSittingChairUB_idle2",
    "HubSittingChairUB_idle3",
    "HubSittingChairUB_move1",
    "HubSittingChairUC_idle1",
    "HubSittingChairUC_idle2",
    "HubSittingChairUC_idle3",
    "HubSittingChairUC_move1"
];

selectRandom _animations