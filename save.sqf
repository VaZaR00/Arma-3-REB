
REB_fnc_toggleReb = {
	// params ["_target", "_caller", "_actionId", "_arguments"];
	params ["_target"];

	PR _reb = _target;
	R_HASH(_reb);

	private _hasActive = GET_HASHS_OBJ_VAL(_reb, "REB_var_hasActiveReb", true, _target);

	[_reb, !_hasActive, _target] call REB_fnc_setRebActive;

	private _text = if (GET_HASHS_OBJ_VAL(_reb, "REB_var_hasActiveReb", true, _target)) then {LOC "$STR_REB_DISABLE"} else {LOC "$STR_REB_ENABLE"};

	_target setUserActionText [(_target getVariable ["REB_TOGGLE_REB_ACTION_ID", -1]), [_target, _text] call REB_fnc_setActionText];
};
REB_fnc_setActionText = {
	params["_reb", ["_text", ""]];

	[player, _reb, (_reb isEqualTo player)] RLOG

	if (_reb isEqualTo player) then {
		format["Self: %1", _text]
	} else {
		_text
	};
};
REB_fnc_setActions = {
	params[["_obj", 0]];

	if !(IS_OBJ(_obj)) exitWith {};

	PR _actionDistance = _obj getVariable ["REB_actionDistance", MGVAR ["REB_global_actionDistance", 2]];

	// ACTIONS
	if !((_obj getVariable ["REB_TOGGLE_REB_ACTION_ID", ""]) isEqualType 1) then {
		private _id = _obj addAction
		[
			[_obj, if !(GET_HASHS_OBJ_VAL(GET_HASH(_obj), "REB_var_hasActiveReb", false, _obj)) then {LOC "$STR_REB_ENABLE"} else {LOC "$STR_REB_DISABLE"}] call REB_fnc_setActionText,
			{
				call REB_fnc_toggleReb;
			},
			nil,
			1.5,
			false,
			true,
			"",
			"alive _target",
			_actionDistance,
			false,
			"",
			""
		];
		_obj setVariable ["REB_TOGGLE_REB_ACTION_ID", _id];
	};

	if !((_obj getVariable ["REB_SET_RANGE_ACTION_ID", ""]) isEqualType 1) then {
		private _id = _obj addAction
		[
			[_obj, LOC "$STR_REB_SET_RANGE"] call REB_fnc_setActionText,
			{
				[(_this#0)] call REB_fnc_setRange;
			},
			nil,
			1.5,
			false,
			true,
			"",
			"alive _target",
			_actionDistance,
			false,
			"",
			""
		];
		_obj setVariable ["REB_SET_RANGE_ACTION_ID", _id];
	};

	if !((_obj getVariable ["REB_SET_STRENGHT_ACTION_ID", ""]) isEqualType 1) then {
		private _id = _obj addAction
		[
			[_obj, LOC "$STR_REB_SET_STRENGHT"] call REB_fnc_setActionText,
			{
				[(_this#0)] call REB_fnc_setStrenght;
			},
			nil,
			1.5,
			false,
			true,
			"",
			"alive _target",
			_actionDistance,
			false,
			"",
			""
		];
		_obj setVariable ["REB_SET_STRENGHT_ACTION_ID", _id];
	};
};
REB_fnc_removeActions = {
	params["_obj"];

	if !(IS_OBJ(_obj)) exitWith {};

	_obj removeAction (_obj getVariable ["REB_TOGGLE_REB_ACTION_PATH", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_RANGE_ACTION_PATH", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_STRENGHT_ACTION_PATH", -1]);

	_obj setVariable ["REB_TOGGLE_REB_ACTION_PATH", nil];
	_obj setVariable ["REB_SET_RANGE_ACTION_PATH", nil];
	_obj setVariable ["REB_SET_STRENGHT_ACTION_PATH", nil];
};