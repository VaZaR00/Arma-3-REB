/*
	Name: REB_fnc_compile

	Author: Vazar
		
	Description:
		Define all main functions

	Arguments: Nothing

	Return Value: Nothing

	Example: call REB_fnc_compile

	Additional: Nothing
*/

#include "defines.h"


/*
	Main functions
*/
REB_fnc_eventHandler = {
	params [
		"_oldUnit", "_newUnit", "_vehicleIn",
		"_oldCameraOn", "_newCameraOn", "_uav"
	];

	REB_noise ppEffectEnable false;
	_uav = if (_newCameraOn isEqualTo player) then {objNull} else {_newCameraOn};
	REB_currentUAV = _uav;

	if (!(_uav isEqualTo objNull)) exitWith {
		[] spawn {
			while {uiSleep REB_freq; (alive player) && (REB_currentUAV isEqualTo (getConnectedUAV player))} do {
				call REB_fnc_main;
			};
		};
	};
};
REB_fnc_main = {
	params [["_freq", REB_freq], ["_random", REB_random], ["_noise", REB_noise], ["_uav", GET_PLAYER_DRONE]];

	_noise ppEffectEnable false; 

	if (_uav getVariable ['ArmaFPV_EnableTI', false]) then {
		_uav disableTIEquipment false;
	};
	// equipmentDisabled _uav params ["_nvg", "_tiDisabled"];
	if (count REB_all_rebs == 0) exitWith {};

	PR _isLancet = ISLANCETHANDL;

	if !((_uav in allUnitsUAV) || _isLancet) exitWith {};

	if (_isLancet) then {
		_uav = uiNamespace getVariable ["lancet_currentProjectile", objNull];
	};

	if (_uav call REB_fnc_isInDeadzone) exitWith {
		_uav call REB_fnc_disconectDrone;
	};

	PR _activeRebStrength = _uav call REB_fnc_currentJammingRebStrength;
	
	IF_NIL_EX(_activeRebStrength);

	_uav disableTIEquipment true;
	
	if (_isLancet) then {
		false setCamUseTI 0;
	};

	_activeRebStrength call REB_fnc_suppress;
};
REB_fnc_currentJammingRebStrength = {
	PR _currentStrength = 0;

	REB_all_rebs apply {
		PR _obj = _x;
		PR _d = (_drone distance _obj);
		OBJ_REBS_LIST(_obj) apply {
			PR _stren = _obj GV [(REB_VAR_PREF + _x + "_strenght"), 0];
			if (
				(_d < (_obj GV [(REB_VAR_PREF + _x + "_range"), -1])) &&
				(_obj GV [(REB_VAR_PREF + _x + "_isActive"), false]) &&
				(_stren > _currentStrength)
			) then {
				_currentStrength = _stren;
			};
		};
	};

	IF_ELSE(_currentStrength <= 0, nil, _currentStrength);
};
REB_fnc_isInDeadzone = {
	PR _isDead = false;

	REB_all_rebs apply {
		PR _obj = _x;
		PR _d = (_drone distance _obj);
		OBJ_REBS_LIST(_obj) apply {
			PR _stren = _obj GV [(REB_VAR_PREF + _x + "_strenght"), 0];
			if (
				(_d < (_obj GV [(REB_VAR_PREF + _x + "_deadzone"), -1])) &&
				(_obj GV [(REB_VAR_PREF + _x + "_isActive"), false])
			) EW {
				_isDead = true;
			};
		};
	};

	_isDead
};
REB_fnc_disconectDrone = {
	if (ISLANCETHANDL) exitWith {
		closeDialog 1;
	};

	player connectTerminalToUAV objNull; //disconnect from players terminal
	_noise ppEffectEnable false; //disable noise
	//delete drone ai crew so drone will fall, otherwise ai will try to hover on 
	deleteVehicleCrew _this; 
	_this spawn {
		uiSleep REB_createUavCrewOnDisconectTime;
		createVehicleCrew _this;
	};
};
REB_fnc_suppress = {
	PR _effect = (random _random) * _this;
	
	_effect call REB_fnc_showEffect;
};
REB_fnc_showEffect = {
	_noise ppEffectEnable true;
	_noise ppEffectAdjust [_this,0,2,2,2,true];
	_noise ppEffectCommit 0;
};
REB_fnc_rebsInDroneRadius = {
	params["_drone", ["_byRange", true]];
	REB_all_rebs select {
		PR _obj = _x;
		PR _d = (_drone distance _obj);
		count (OBJ_REBS_LIST(_obj) select {
			(
				(_d < (_obj GV [(REB_VAR_PREF + _x + IF_ELSE(_byRange, "_range", "_deadzone")), -1])) &&
				(_obj GV [(REB_VAR_PREF + _x + "_isActive"), false])
			)
		}) > 0;
	};
};

// REB_fnc_rebItemHandle = {
// 	//check unit inventory and _container if its replaced
// 	params ["_isTake", "_args"];
// 	_args params ["_unit", "_container", "_item"];

// 	[_container] spawn REB_fnc_handleContainer;

// 	if (_isTake && (H_PREF(_item) in REB_itemRebsClasses)) then {
// 		_unit setVariable ["REB_var_currentRebItem", _item, true];

// 		[_unit, _item, _container] call REB_fnc_changeRebOnObj;
// 	} else {
// 		if (_unit in REB_all_rebs) then {[_unit, objNull] call REB_fnc_setRebToObj};
// 		_unit setVariable ["REB_var_currentRebItem", nil, true];
// 	};
// };
// REB_fnc_handleContainer = {
// 	params["_container", ["_item", ""]];

// 	if (_container isEqualTo objNull) exitWith {};

// 	PR _allContainerItems = (((everyContainer _container) apply {_x#0}) + ((getItemCargo _container)#0)) apply {WITH_PREF(_x)};
// 	PR _rebsInContainer = (if (STR_EMPTY(_item)) then {(keys REB_all_hashes)} else {[_item]}) select {WITH_PREF(_x) in _allContainerItems};

// 	_rebsInContainer pushBack _container;

// 	PR _rebItem = "";
// 	PR _hasSet = if (count _rebsInContainer > 0) then {
// 		PR _rebsSorted = ([
// 			_rebsInContainer, 
// 			[], 
// 			{GET_HASHS_OBJ_VAL(GET_HASH(_x), "REB_var_rebMaxRange", 0, _x)}, 
// 			"DESCEND", 
// 			{GV_HAS_ACTIVE_REB_TRUE(_x) && (IS_HASH(GET_INIT_HASH(_x)))}
// 		] call BIS_fnc_sortBy);

// 		if (count _rebsSorted == 0) exitWith {false};

// 		_rebItem = _rebsSorted#0;

// 		if !(IS_HASH(GET_INIT_HASH(_rebItem))) EW {false};

// 		// if !((_container GV ["REB_var_currentRebItem", ""]) isEqualTo _rebItem) EW {false};
		
// 		[_container, _rebItem, player] call REB_fnc_changeRebOnObj;
// 		_container setVariable ["REB_var_currentRebItem", _rebItem, true];
// 		true
// 	} else {false};

// 	_rebsInContainer apply {
// 		[_container, GET_HASH(_x)] remoteExec ["REB_fnc_createAceMenuAction", 0];
// 	};

// 	if (_hasSet) exitWith {true};

// 	if (_container in REB_all_rebs) then {
// 		// [_container] call REB_fnc_removeReb;
// 		[_container, objNull] call REB_fnc_setRebToObj;
// 	};
// 	_container setVariable ["REB_var_currentRebItem", nil, true];

// 	false
// };
REB_fnc_off = {
	true	
};

/*
	Misc functions
*/
REB_fnc_isReb = {
	if (ARR_EMPTY(OBJ_REBS_LIST(_this))) EW {false};

	true
};
REB_fnc_makeRebClassname = {
	if (IS_STR(_this) && {REB_CLS_PREF in _this}) EW {_this};

	REB_CLS_PREF +
	(if (IS_STR(_this)) then {
		_this
	} else {
		hashValue _this;
	});
};