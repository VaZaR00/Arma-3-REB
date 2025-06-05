params["_reb", "_var", ["_val", "-1"]];

private _v = _val call BIS_fnc_parseNumber;

if !(_v isEqualType 0) exitWith {};
if (_v isEqualTo -1) exitWith {};

_uav setVariable [_var, _v, true];