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

	LOG [_activeRebStrength];

	_uav disableTIEquipment true;
	
	if (_isLancet) then {
		false setCamUseTI 0;
	};

	_activeRebStrength call REB_fnc_suppress;
};
REB_fnc_currentJammingRebStrength = {
	PR _currentStrength = 0;

	REB_all_rebs apply {
		PR _obj = _y;
		PR _d = (_this distance _obj);
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
		PR _obj = _y;
		PR _d = (_this distance _obj);
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
REB_fnc_disableSystem = {
	true	
};

/*
	Handle objects functions
*/
REB_fnc_addRebOnObj = {
	EXEC_ON_SERVER_START
		params['_obj', '_rebObj', ['_itemRef', objNull]];

		METHOD(GET_REB_INSTANCE(_rebObj), "New_object_reb", [_obj C _itemRef]);
	EXEC_ON_SERVER_END
};
REB_fnc_removeRebOnObj = {
	EXEC_ON_SERVER_START 
		params['_obj', '_rebObj', ['_itemRef', objNull]];

		METHOD(GET_REB_INSTANCE(_rebObj), "Delete_object_reb", [_obj C _itemRef]);
	EXEC_ON_SERVER_END
};
REB_fnc_rebItemHandle = {
	//check unit inventory and _container if its replaced
	
	params ["_isTake", "_args"];
	_args params ["_unit", "_container", "_item"];

	GET_CURR_ITEMS_VAR(_unit);
	

	PR _isRebItem = (RC_PREF(_item) in REB_all_classes);

	if (_isTake) then {
		0 RLOG
		if (_isRebItem) then {
		0.1 RLOG
			ADD_TO_CURR_ITEMS(_item);
			SAVE_CURR_ITEMS_VAR(_unit);

			[_unit, _item] call REB_fnc_addRebOnObj;
			[_container, _item] call REB_fnc_removeRebOnObj;

			REB_currentBackpack = [backpack player, backpackContainer player];
		} else {
		0.11 RLOG
			waitUntil { !(isNil "REB_slotChanged") };
		0.12 RLOG
			if (REB_slotChanged) then {
		0.13 RLOG
				[_container] call REB_fnc_handleContainer;
			};
		};
	} else {
		1 RLOG
		if (_isRebItem) then {
		1.1 RLOG
			[_unit, _item] call REB_fnc_removeRebOnObj;
			[_container, _item] call REB_fnc_addRebOnObj;
		};
	};
	REB_slotChanged = nil;
};
REB_fnc_initRebItemSystem = {
	if (REB_var_rebItemsSystemInited) exitWith {};

	if !((missionNamespace getVariable ["REB_ON_PUT_EH", ""]) isEqualType 1) then {
		REB_ON_PUT_EH = player addEventHandler ["Put", {
			[false, _this] spawn REB_fnc_rebItemHandle;
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_TAKE_EH", ""]) isEqualType 1) then {
		REB_ON_TAKE_EH = player addEventHandler ["Take", {
			[true, _this] spawn REB_fnc_rebItemHandle;
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_SLOT_CHANGED_EH", ""]) isEqualType 1) then {
		REB_ON_SLOT_CHANGED_EH = player addEventHandler ["SlotItemChanged", {
			params ["_unit", "_name", "_slot", "_assigned", "_weapon"];

			if (_slot != 901) EX; // handle only backpacks

			REB_slotChanged = true;
		}];
	};

	if (isServer) then {
		[] spawn REB_fnc_initRebItems;
	};
	
	REB_var_rebItemsSystemInited = true;
};
REB_fnc_initRebItems = {
	params[["_items", ""]];

	if !(isNil "REB_initingRebItems") exitWith {};
	REB_initingRebItems = _thisScript;

	if !(IS_ARR(_items)) then {
		if (STR_EMPTY(_items)) then {
			_items = keys REB_all_classes;
		} else {
			_items = [_items];
		};
	};

	(allUnits + vehicles + ("GroundWeaponHolder" allObjects 0)) apply {
		[_x] call REB_fnc_handleContainer
	};
	REB_initingRebItems = nil;
};
REB_fnc_handleContainer = {
	if (IS_OBJNULL(_this#0)) EX;

	EXEC_ON_SERVER_START
		METHOD(IOO_OBJECT_REB_DB, "Handle_container", [_this#0]);
	EXEC_ON_SERVER_END
};
REB_fnc_setEventHandlers = {
	params[["_obj", 0]];

	if !(IS_OBJ(_obj)) exitWith {};

	if !((_obj getVariable ["REB_DELETED_EH", ""]) isEqualType 1) then {
		private _eh = _obj addEventHandler ["Deleted", {
			params ["_entity"];
			[_entity, true] call REB_fnc_removeReb;
		}];
		_obj setVariable ["REB_DELETED_EH", _eh];
	};

	if !((_obj getVariable ["REB_KILLED_EH", ""]) isEqualType 1) then {
		private _eh = _obj addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[_unit, true] call REB_fnc_removeReb;
		}];

		_obj setVariable ["REB_KILLED_EH", _eh];
	};
};
REB_fnc_removeEventHandlers = {
	params[["_obj", 0]];

	if !(IS_OBJ(_obj)) exitWith {};

	_obj removeEventHandler ["Deleted", (_obj getVariable ["REB_DELETED_EH", -1])];
	_obj removeEventHandler ["Killed", (_obj getVariable ["REB_KILLED_EH", -1])];

	_obj setVariable ["REB_DELETED_EH", nil];
	_obj setVariable ["REB_KILLED_EH", nil];
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
		HASHVAL_(_this);
	});
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