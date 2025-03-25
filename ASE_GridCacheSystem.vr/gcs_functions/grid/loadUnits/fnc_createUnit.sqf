params["_name", "_type", "_side", "_damage", "_position", "_direction", "_unitPos", "_group", "_rank", "_skill", "_behaviour", "_speed"];

_unit = _group createUnit [_type, _position, [], 0, "CAN_COLLIDE"];

_unit setName _name;
_unit setDir _direction;
_unit setPosASL _position;
_unit setRank _rank;
_unit setSkill _skill;
_unit setUnitPos _unitPos;
_unit setDamage _damage;
_unit setBehaviour _behaviour;
_unit setSpeedMode _speed;

_unit setSkill ["aimingAccuracy", 0.02];
_unit setSkill ["aimingShake", 0.1];
_unit setSkill ["spotTime", 0.4];
_unit setSkill ["courage", 1];
_unit setSkill ["spotDistance", 0.5];

_unit;