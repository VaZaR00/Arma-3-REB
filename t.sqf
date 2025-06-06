{
params["_hash", "_obj", ["_add", true]];

if (!((_hash isEqualType createHashMap)) || !((_obj isEqualType objNull))) exitWith {};

private _currObjs = _hash getOrDefault ["HASH_CURRENT_OBJS", []];

if ((_currObjs isEqualType [])) then {
private _i = _currObjs find _obj;
if (_add) then {
if ((_i == -1)) then { (_currObjs pushBack _obj)};
} else {
if ((_i != -1)) then { (_currObjs deleteAt _i)};
};
} else {
_currObjs = if (_add) then { [_obj]} else { []};
};

_hash set ["HASH_CURRENT_OBJS", _currObjs];
missionNamespace setVariable [(_hash get "HASH_VAR_NAME"), _hash, true];;
}