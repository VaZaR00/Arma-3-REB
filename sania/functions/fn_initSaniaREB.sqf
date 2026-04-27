_this spawn {

params["_reb"];

_reb setVariable ["Object", _reb];
private _radius = (_reb getVariable ["Radius", "100"]) call BIS_fnc_parseNumber;
private _deadzone = (_reb getVariable ["Deadzone", "30"]) call BIS_fnc_parseNumber;
private _strength = (_reb getVariable ["Strength", "0.5"]) call BIS_fnc_parseNumber;
private _isAttachable = (_reb getVariable ["IsAttachable", "0"]) call BIS_fnc_parseNumber;
private _canModifyRange = (_reb getVariable ["CanModifyRange", "1"]) call BIS_fnc_parseNumber;
private _canModifyStrength = (_reb getVariable ["CanModifyStrength", "0"]) call BIS_fnc_parseNumber;
private _isActive = (_reb getVariable ["IsActive", "1"]) call BIS_fnc_parseNumber;

if (_radius != -1) then {
	_reb setVariable ["Radius", _radius];
};
if (_deadzone != -1) then {
	_reb setVariable ["Deadzone", _deadzone];
};
if (_strength != -1) then {
	_reb setVariable ["Strength", _strength];
};
if (_isAttachable != -1) then {
	_reb setVariable ["IsAttachable", _isAttachable];
};
if (_canModifyRange != -1) then {
	_reb setVariable ["CanModifyRange", _canModifyRange];
};
if (_canModifyStrength != -1) then {
	_reb setVariable ["CanModifyStrength", _canModifyStrength];
};
if (_isActive != -1) then {
	_reb setVariable ["IsActive", _isActive];
};
_reb setVariable ["ActionsOnlyForCrew", 0];

[_reb] call REB_fnc_initModuleRebDevice;

};