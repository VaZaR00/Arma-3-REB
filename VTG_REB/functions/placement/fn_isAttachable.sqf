params["_object", ["_can", true]];

if (isNull _object) exitWith {};

_object setVariable ["REB_attachable", _can, true];

// we add action only once
if (_can && (_object getVariable ["REB_attachable", false])) then {
	[
		_object, 
		"<t color='#0ed145'>Attach Object</t>", 
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", 
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", 
		'(alive _target) && {(isNull (player getVariable ["REB_currentAttachObj", objNull])) && (_target getVariable ["REB_attachable", false]) && {(_this distance _target < 3)}}', 
		'(alive _target) && {(isNull (player getVariable ["REB_currentAttachObj", objNull])) && (_target getVariable ["REB_attachable", false]) && {(_this distance _target < 3)}}', 
		{}, 
		{}, 
		{ [_target] call REB_fnc_handleAttachment }, 
		{}, 
		[], 
		(missionNamespace getVariable ["REB_attach_actionTime", 5]), 
		0, 
		false, 
		false
	] remoteExec ["BIS_fnc_holdActionAdd", 0, true];
};