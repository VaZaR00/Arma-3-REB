_this spawn {

params["_reb"];

// sleep 0.1;

// if !(missionNamespace getVariable ["REB_var_INITED", false]) then {
// 	REB_var_START_INIT = true;
// };

[
	_reb, 
	_reb getVariable ['REB_var_rebMaxRange', 200], 
	_reb getVariable ['REB_var_rebMaxDeadzone', 100], 
	_reb getVariable ['REB_var_rebMaxStrength', 0.8],
	nil,
	_reb getVariable ['REB_var_canChangeRange', true],
	_reb getVariable ['REB_var_canChangeStrength', true],
	_reb getVariable ['REB_var_hasActiveReb', true]
] spawn REB_fnc_reb;

};