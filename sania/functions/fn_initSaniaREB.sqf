_this spawn {

params["_reb"];

_reb setVariable ["Object", _reb];
private _radius = (_reb getVariable ["Radius", "100"]) call BIS_fnc_parseNumber;
private _deadzone = (_reb getVariable ["Deadzone", "30"]) call BIS_fnc_parseNumber;
private _strength = (_reb getVariable ["Strength", "0.5"]) call BIS_fnc_parseNumber;
private _simulatedHealth = (_reb getVariable ["SimulatedHealth", "100"]) call BIS_fnc_parseNumber;

if (_radius != -1) then {
	_reb setVariable ["Radius", _radius];
};
if (_deadzone != -1) then {
	_reb setVariable ["Deadzone", _deadzone];
};
if (_strength != -1) then {
	_reb setVariable ["Strength", _strength];
};
if (_simulatedHealth != -1) then {
	_reb setVariable ["SimulatedHealth", _simulatedHealth];
};
_reb setVariable ["ActionsOnlyForCrew", 0];

[_reb] call REB_fnc_initModuleRebDevice;

};