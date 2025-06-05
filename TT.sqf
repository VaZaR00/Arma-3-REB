_obj setVariable ["REB_var_hasActiveReb", _active, true];
_obj setVariable ["REB_var_rebRange", _radius, true];
_obj setVariable ["REB_var_rebDeadzone", _deadzone, true];
_obj setVariable ["REB_var_rebStrength", _strenght, true];
if ((_obj getVariable ["REB_var_rebMaxRange", -1]) isEqualTo -1) then {
	_obj setVariable ["REB_var_rebMaxRange", _radius, true];
};
if ((_obj getVariable ["REB_var_rebMaxDeadzone", -1]) isEqualTo -1) then {
	_obj setVariable ["REB_var_rebMaxDeadzone", _deadzone, true];
};
if ((_obj getVariable ["REB_var_rebMaxStrength", -1]) isEqualTo -1) then {
	_obj setVariable ["REB_var_rebMaxStrength", _strenght, true];
};
if ((_obj getVariable ["REB_var_rebRatio", -1]) isEqualTo -1) then {
	_obj setVariable ["REB_var_rebRatio", (_radius / _deadzone), true];
};