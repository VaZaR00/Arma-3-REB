#include "defines.h"


REB_aceMenuAction_disableReb = {["REB_disableReb", LOC "$STR_REB_DISABLE", "", {
	// statement 
    params ["_target", ["_player", player], ["_params", []]];
	[_target] call REB_fnc_toggleReb;
}, {
	// condition
	HAS_ACTIVE_REB(_this#0)
}, {
	// insertChildren 
    params ["_target", ["_player", player], ["_params", []]];
	[]
}, [_this], [0, 0, 0], 2, [false, false, false, false, false], {
	// modifier
    params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];
}]};


REB_aceMenuAction_enableReb = {["REB_enableReb", LOC "$STR_REB_ENABLE", "", {
	// statement 
    params ["_target", ["_player", player], ["_params", []]];
	[_target] call REB_fnc_toggleReb;
}, {
	// condition
	!HAS_ACTIVE_REB(_this#0)
}, {
	// insertChildren 
    params ["_target", ["_player", player], ["_params", []]];
	[]
}, [_this], [0, 0, 0], 2, [false, false, false, false, false], {
	// modifier
    params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];
}]};


REB_aceMenuAction_setRange = {["REB_setRange", LOC "$STR_REB_SET_RANGE", "", {
	// statement 
    params ["_target", ["_player", player], ["_params", []]];
	[_target] call REB_fnc_setRange;
}, {
	// condition
	true
}, {
	// insertChildren 
    params ["_target", ["_player", player], ["_params", []]];
	[]
}, [_this], [0, 0, 0], 2, [false, false, false, false, false], {
	// modifier
    params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];
}]};


REB_aceMenuAction_setStrenght = {["REB_setStrenght", LOC "$STR_REB_SET_STRENGHT", "", {
	// statement 
    params ["_target", ["_player", player], ["_params", []]];
	[_target] call REB_fnc_setStrenght;
}, {
	// condition
	true
}, {
	// insertChildren 
    params ["_target", ["_player", player], ["_params", []]];
	[]
}, [_this], [0, 0, 0], 2, [false, false, false, false, false], {
	// modifier
    params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];
}]};

REB_fnc_createAceMenuRebAction = {
	params[["_obj", 0]];

	if !(IS_OBJ(_obj)) exitWith {""};

	PR _rebAct = _obj GV ["REB_mainRebAction", ""];

	if !(STR_EMPTY(_rebAct)) exitWith {_rebAct};

	PR _action = ["REB_mainAction", "REB", "", {
		// statement 
		params ["_target", ["_player", player], ["_params", []]];
	}, {
		// condition
		IS_REB(_this#0)
	}, {
		// insertChildren 
		params ["_target", ["_player", player], ["_params", []]];
		[]
	}, [_obj], [0, 0, 0], 2, [false, false, false, false, false], {
		// modifier
		params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];
	}] call ace_interact_menu_fnc_createAction;

	PR _actionPath = [_obj, IF_ELSE(_obj isEqualTo player, 1, 0), if (_obj isEqualTo player) then {["ACE_SelfActions", "ACE_Equipment"]} else {["ACE_MainActions"]}, _action] call ace_interact_menu_fnc_addActionToObject;
	_obj SV ["REB_mainRebAction", "REB_mainAction"];

	"REB_mainAction"
};

REB_fnc_createAceMenuAction = {
	params[["_obj", 0], ["_curHsh", 0]];

	if !(IS_OBJ(_obj)) exitWith {};

	_curHsh = IF_ELSE(!IS_HASH(_curHsh), CURR_HASH(_obj), _curHsh);
	if (!IS_HASH(_curHsh)) exitWith {};
	PR _curHshN = HASH_NAME(_curHsh);
	PR _curActs = _obj GV ["REB_currentRebActions", createHashMap];

	if (_curHshN in _curActs) exitWith {};

	PR _initObj = _curHsh getDef ["HASH_INIT_OBJ", "REB"];
	PR _initObjCls = IF_ELSE(IS_STR(_initObj), _initObj, typeOf _initObj);
	PR _actName = [configFile >> "CfgVehicles" >> _initObjCls] call BIS_fnc_displayName;

	PR _parentAct = [_obj] call REB_fnc_createAceMenuRebAction;

	PR _action = [_initObjCls, _actName, "", {
		// statement 
		params ["_target", ["_player", player], ["_params", []]];
	}, {
		// condition
		IS_REB(_this#0)
	}, {
		// insertChildren 
		params ["_target", ["_player", player], ["_params", []]];

		[
			REB_aceMenuAction_disableReb,
			REB_aceMenuAction_enableReb,
			REB_aceMenuAction_setRange,
			REB_aceMenuAction_setStrenght
		] apply {
			[(_target call _x) call ace_interact_menu_fnc_createAction, [], _target]
		};

	}, [_obj], [0, 0, 0], 2, [false, false, false, false, false], {
		// modifier
		params ["_target", ["_player", player], ["_params", []], ["_actionData", []]];

		// _actionData set [1, format ["%1: %2", count (items player)]];
	}] call ace_interact_menu_fnc_createAction;

	PR _actionPath = [_obj, IF_ELSE(_obj isEqualTo player, 1, 0), if (_obj isEqualTo player) then {["ACE_SelfActions", "ACE_Equipment"]} else {["ACE_MainActions", _parentAct]}, _action] call ace_interact_menu_fnc_addActionToObject;
	_curActs set [_curHshN, [_obj, IF_ELSE(_obj isEqualTo player, 1, 0), _actionPath]];
	_obj SV ["REB_currentRebActions", _curActs];
};

REB_fnc_removeAceMenuAction = {
	params["_obj", "_rebHash"];

	if !(IS_OBJ(_obj)) exitWith {};
	if !(IS_HASH(_rebHash)) exitWith {};

	PR _curActs = _obj GV ["REB_currentRebActions", createHashMap];
	PR _curHshN = HASH_NAME(CURR_HASH(_obj));

	if !(_curHshN in _curActs) exitWith {};

	PR _act = _curActs get _curHshN;

	_act call ace_interact_menu_fnc_removeActionFromObject;

	_curActs deleteAt _curHshN;
	if (ARR_EMPTY(_curActs)) then {
		_obj SV ["REB_currentRebActions", _curActs];
	} else {
		_obj SV ["REB_currentRebActions", nil];
	};
};

