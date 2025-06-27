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


REB_fnc_main = {
	params [["_freq", REB_freq], ["_random", REB_random], ["_noise", REB_noise], ["_uav", vehicle (remoteControlled player)]];

	_noise ppEffectEnable false; 
	// equipmentDisabled _uav params ["_nvg", "_tiDisabled"];

	if (_uav getVariable ['ArmaFPV_EnableTI', false]) then {
		_uav disableTIEquipment false;
	};

	if !((_uav in allUnitsUAV) || ISLANCETHANDL) exitWith {};

	PR _rebs = +REB_all_rebs;

	if (count _rebs == 0) exitWith {};

	if (ISLANCETHANDL) then {
		_uav = uiNamespace getVariable ["lancet_currentProjectile", objNull];
	};

	PR _activeRebs = _rebs select {[_x, true] call REB_fnc_selectReb};
	PR _deadZoneRebs = _rebs select {[_x, false] call REB_fnc_selectReb};

	if (count _deadZoneRebs != 0) exitWith {
		_uav call REB_fnc_disconectDrone;
	};
	if (count _activeRebs == 0) exitWith {};

	_uav disableTIEquipment true;
	
	if (ISLANCETHANDL) then {
		false setCamUseTI 0;
	};
	_activeRebs call REB_fnc_suppress;
};
REB_fnc_off = {
	true	
};
REB_fnc_isDroneInRadius = {
	params ["_reb", "_uav", "_radius"];

	PR _attachedToObj = attachedTo _reb;

	// check if reb is loaded in cargo 
	if !(_attachedToObj isEqualTo objNull) then {
		if (_reb in (_attachedToObj getVariable ["ace_cargo_loaded", []])) then {
			_reb = _attachedToObj;
		};
	};

	_res = ((_reb distance _uav) < _radius);

	_res
};
REB_fnc_selectReb = {
	params["_reb", ["_checkRadius", true]];

	PR _obj = _reb;
	R_HASH(_reb);

	(GET_HASHS_OBJ_VAL(_reb, "REB_var_hasActiveReb", false, _obj)) && {
		[
			_obj, 
			_uav, 
			GET_HASHS_OBJ_VAL(_reb, if (_checkRadius) then {"REB_var_rebRange"} else {"REB_var_rebDeadzone"}, -1, _obj)
		] call REB_fnc_isDroneInRadius
	}
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
REB_fnc_showEffect = {
	_noise ppEffectEnable true;
	_noise ppEffectAdjust [_this,0,2,2,2,true];
	_noise ppEffectCommit 0;
};
REB_fnc_suppress = {
	PR _sortedByStrenght = [_this, [], { (GET_HASHS_OBJ_VAL(GET_HASH(_x), "REB_var_rebStrength", 0, _x)) }, "DESCEND"] call BIS_fnc_sortBy; 

	PR _activeReb = _sortedByStrenght#0;
	PR _strenght = GET_HASHS_OBJ_VAL(GET_HASH(_activeReb), "REB_var_rebStrength", 0, _activeReb) ^ (1 / (count _sortedByStrenght));
	
	PR _effect = (random _random) * _strenght;
	
	_effect call REB_fnc_showEffect;
};
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
REB_fnc_rebItemHandle = {
	//check unit inventory and _container if its replaced
	params ["_isTake", "_args"];
	_args params ["_unit", "_container", "_item"];

	[_container] spawn REB_fnc_handleContainer;

	if (_isTake && (H_PREF(_item) in REB_itemRebsClasses)) then {
		_unit setVariable ["REB_var_currentRebItem", _item, true];

		[_unit, _item, _container] call REB_fnc_changeRebOnObj;
	} else {
		if (_unit in REB_all_rebs) then {[_unit, objNull] call REB_fnc_setRebToObj};
		_unit setVariable ["REB_var_currentRebItem", nil, true];
	};
};
REB_fnc_handleContainer = {
	params["_container", ["_item", ""]];

	if (_container isEqualTo objNull) exitWith {};

	PR _allContainerItems = (((everyContainer _container) apply {_x#0}) + ((getItemCargo _container)#0)) apply {WITH_PREF(_x)};
	PR _rebsInContainer = (if (STR_EMPTY(_item)) then {(keys REB_all_hashes)} else {[_item]}) select {WITH_PREF(_x) in _allContainerItems};

	_rebsInContainer pushBack _container;

	PR _rebItem = "";
	PR _hasSet = if (count _rebsInContainer > 0) then {
		PR _rebsSorted = ([
			_rebsInContainer, 
			[], 
			{GET_HASHS_OBJ_VAL(GET_HASH(_x), "REB_var_rebMaxRange", 0, _x)}, 
			"DESCEND", 
			{GV_HAS_ACTIVE_REB_TRUE(_x) && (IS_HASH(GET_INIT_HASH(_x)))}
		] call BIS_fnc_sortBy);

		if (count _rebsSorted == 0) exitWith {false};

		_rebItem = _rebsSorted#0;

		if !(IS_HASH(GET_INIT_HASH(_rebItem))) EW {false};

		// if !((_container GV ["REB_var_currentRebItem", ""]) isEqualTo _rebItem) EW {false};
		
		[_container, _rebItem, player] call REB_fnc_changeRebOnObj;
		_container setVariable ["REB_var_currentRebItem", _rebItem, true];
		true
	} else {false};

	_rebsInContainer apply {
		[_container, GET_HASH(_x)] remoteExec ["REB_fnc_createAceMenuAction", 0];
	};

	if (_hasSet) exitWith {true};

	if (_container in REB_all_rebs) then {
		// [_container] call REB_fnc_removeReb;
		[_container, objNull] call REB_fnc_setRebToObj;
	};
	_container setVariable ["REB_var_currentRebItem", nil, true];

	false
};


REB_fnc_isReb = {
	params["_obj"];

	if (ARR_EMPTY(OBJ_REBS_LIST(_obj))) EW {false};

	true
};