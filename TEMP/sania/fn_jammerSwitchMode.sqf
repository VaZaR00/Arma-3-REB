params ["_jammer"];

private _status = !(_jammer getVariable ["DB_jammer_isActive", false]);

_jammer setVariable ["DB_jammer_isActive", _status, true];

hintSilent format ["The jammer is %1", ["OFF", "ON"] select _status];