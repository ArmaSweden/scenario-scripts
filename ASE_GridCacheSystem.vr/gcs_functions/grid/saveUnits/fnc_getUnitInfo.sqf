params["_unit", "_group", "_groupName", "_leaderUnit"];

private _nameUnit = name _unit;
private _className = typeof _unit;
private _side = side _unit;
private _damage = damage _unit;
private _position = getPosASL _unit;
private _direction = getDir _unit;
private _unitPos = unitPos _unit;
private _isleader = _unit isEqualTo _leaderUnit;
private _rank = rank _unit;
private _skill = skill _unit;
private _behaviour = behaviour _unit;
private _speed = speedMode _unit;

if (_isleader) then
{
    private _waypointsInfo = [group _unit] call GCS_fnc_grid_saveUnits_saveWaypoints;
    [_nameUnit, _className, _side, _damage, _position, _direction, _unitPos, _group, _groupName, _leaderUnit, _isleader, _rank, _skill, _behaviour, _speed, _waypointsInfo]
}
else
{
    [_nameUnit, _className, _side, _damage, _position, _direction, _unitPos, _group, _groupName, _leaderUnit, _isleader, _rank, _skill, _behaviour, _speed]
};