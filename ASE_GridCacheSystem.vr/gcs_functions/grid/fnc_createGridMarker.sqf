params["_posGrid", "_name", "_size", "_color", "_gridSquareSize"];
private["_marker", "_pos"];

_pos = [_posGrid, _gridSquareSize] call GCS_fnc_grid_gridToPos;

_marker = format ["%1_%2_%3", _name, _posGrid select 0, _posGrid select 1];
_marker = createMarker [_marker,  _pos];
_marker setMarkerSize [(_size/2)-.1, (_size/2)-.1];
_marker setMarkerShape "RECTANGLE";
_marker setMarkerBrush "SolidBorder";
_marker setMarkerColor _color;

_marker