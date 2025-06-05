#include "defines.h"
#define ISLANCET ("lancet_tripod_launcher" in (typeOf vehicle player))
#define ISLANCETHANDL (ISLANCET && dialog)
#define HGVAR _hash get

// Define functions
REB_fnc_main = {
	params ["_freq", "_random", "_noise", ["_uav", vehicle (remoteControlled player)]];

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

	PR _selectF = {
		params["_reb", ["_checkRadius", true]];

		PR _obj = _reb;
		R_HASH(_reb);

		(_reb getDef ["REB_var_hasActiveReb", false]) && {
			[
				_obj, 
				_uav, 
				_reb getDef [if (_checkRadius) then {"REB_var_rebRange"} else {"REB_var_rebDeadzone"}, -1]
			] call REB_fnc_isDroneInRadius
		}
	};

	PR _activeRebs = _rebs select {[_x, true] call _selectF};
	PR _deadZoneRebs = _rebs select {[_x, false] call _selectF};

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
REB_fnc_eventHandler = {
	params ["_args", "_thisArgs"];
	// _args params [
	// 	"_oldUnit", "_newUnit", "_vehicleIn",
	// 	"_oldCameraOn", "_newCameraOn", "_uav"
	// ];

	(_thisArgs#2) ppEffectEnable false; 
	_uav = vehicle (remoteControlled player);

	if (!(_uav isEqualTo objNull) || ISLANCET) exitWith {
		_thisArgs spawn {
			params ["_freq", "_random", "_noise"];
			while {uiSleep _freq; (alive player) && ((vehicle (remoteControlled player)) isEqualTo (getConnectedUAV player))} do {
				call REB_fnc_main;
			};
		};
	};
};

REB_fnc_initRebItemSystem = {
	if (REB_var_rebItemsSystemInited) exitWith {};

	if !((missionNamespace getVariable ["REB_ON_PUT_EH", ""]) isEqualType 1) then {
		REB_ON_PUT_EH = player addEventHandler ["Put", {
			[false, _this] call REB_fnc_rebItemHandle;
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_TAKE_EH", ""]) isEqualType 1) then {
		REB_ON_TAKE_EH = player addEventHandler ["Take", {
			[true, _this] call REB_fnc_rebItemHandle;
		}];
	};

	if (isServer) then {
		[] call REB_fnc_initRebItems;
	};
	
	// [] spawn {
	// 	sleep 5;

	// 	if (count REB_itemRebsClasses == 0) exitWith {};

	// 	PR _allHolders = "GroundWeaponHolder" allObjects 0;

	// 	_allHolders apply {
	// 		if (local _x) then {
	// 			[_x] call REB_fnc_handleContainer;
	// 		};
	// 	};
	// };
	REB_var_rebItemsSystemInited = true;
};
REB_fnc_initRebItems = {
	params[["_items", ""]];

	if !(IS_ARR(_items)) then {
		if (STR_EMPTY(_items)) then {
			_items = keys REB_all_hashes;
		} else {
			_items = [_items];
		};
	};

	(allUnits + vehicles + ("GroundWeaponHolder" allObjects 0)) apply {
		_o = _x;
		{
			[_o, _x] call REB_fnc_handleContainer;
		} forEach _items;
	};
};
REB_fnc_setRebToObj = {
	params["_newObj", ["_reb", objNull]];

	PR _hash = [_reb] call REB_fnc_getObjHash;
	PR _currentHash = OBJ_CURR_HASH(_newObj);

	LOG[_newObj, _reb, IS_HASH(_hash), IS_HASH(_currentHash), (_hash isEqualTo _currentHash)];

	if (_hash isEqualTo _currentHash) exitWith {};


	[{[_this] call REB_fnc_updateAllRebsArr}, _newObj] call CBA_fnc_execNextFrame;

	if (IS_HASH(_currentHash)) then {
		_currentHash set ["HASH_CURRENT_OBJ", objNull];
		SAVE_HASH(_currentHash)
	};
	if !(IS_HASH(_hash)) exitWith {
		// removing
		_newObj setVariable ["REB_currentRebHash", nil, true];
		_newObj remoteExec ["REB_fnc_removeActions", 0];
	};

	// setting
	_hash set ["HASH_CURRENT_OBJ", _newObj];
	SAVE_HASH(_hash)

	_newObj setVariable ["REB_currentRebHash", compile HASH_NAME(_hash), true];

	_newObj remoteExec ["REB_fnc_setActions", 0];
};
REB_fnc_updateAllRebsArr = {
	params[["_o", REB_all_rebs]];

	if !(IS_ARR(_o)) then {_o = [_o]};

	{
		if !(IS_OBJ(_x)) then {SKIP};

		PR _curHash = OBJ_CURR_HASH(_x);

		PR _i = REB_all_rebs find _x;

		if (!(IS_HASH(_curHash)) && (_i != -1)) then {
			REB_all_rebs deleteAt _i;
		};
		if ((IS_HASH(_curHash)) && (_i == -1)) then {
			REB_all_rebs pushBack _x;
		};
	} forEach _o;

	MSVAR ["REB_all_rebs", REB_all_rebs, true];
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
REB_fnc_disconectDrone = {
	if (ISLANCETHANDL) exitWith {
		closeDialog 1;
	};

	player connectTerminalToUAV objNull; //disconnect from players terminal
	_noise ppEffectEnable false; //disable noise
	//delete drone ai crew so drone will fall, otherwise ai will try to hover on 
	_this spawn {
		deleteVehicleCrew _this; 
		uiSleep 10;
		createVehicleCrew _this;
	};
};
REB_fnc_showEffect = {
	_noise ppEffectEnable true;
	_noise ppEffectAdjust [_this,0,2,2,2,true];
	_noise ppEffectCommit 0;
};
REB_fnc_suppress = {
	PR _sortedByStrenght = [_this, [], { (_x getVariable "REB_var_rebStrength") }, "DESCEND"] call BIS_fnc_sortBy; 

	PR _activeReb = _sortedByStrenght#0;
	PR _strenght = (_activeReb getVariable "REB_var_rebStrength") ^ (1 / (count _sortedByStrenght));
	
	PR _effect = (random _random) * _strenght;
	
	_effect call REB_fnc_showEffect;
};

REB_fnc_setRebActive = {
	params[["_reb", ""], ["_state", true]];

	R_HASH(_reb);

	SET_HASH_VAL(_reb, "REB_var_hasActiveReb", _state)
};
REB_fnc_toggleReb = {
	params ["_target", "_caller", "_actionId", "_arguments"];

	PR _reb = _target;
	R_HASH(_reb);

	private _hasActive = (_reb getDef ["REB_var_hasActiveReb", true]);

	[_reb, !_hasActive] call REB_fnc_setRebActive;

	private _text = if (_reb getDef ["REB_var_hasActiveReb", true]) then {LOC "$STR_REB_DISABLE"} else {LOC "$STR_REB_ENABLE"};

	_target setUserActionText [(_target getVariable ["REB_TOGGLE_REB_ACTION_ID", -1]), _text];
};
REB_fnc_handleContainer = {
	params["_container", ["_item", ""]];

	if (_container isEqualTo objNull) exitWith {};

	PR _allContainerItems = (((everyContainer _container) apply {_x#0}) + ((getItemCargo _container)#0)) apply {HASH_PREF + _x};
	PR _rebsInContainer = (if (STR_EMPTY(_item)) then {(keys REB_all_hashes)} else {[_item]}) select {_x in _allContainerItems};

	if (count _rebsInContainer > 0) then {
		// private _biggestRadius = 0;
		// private _strongest = "";

		// {


		// 	if ((_y getVariable ["REB_var_rebRange", -1]) < _biggestRadius) then {continue};

		// 	_biggestRadius = _y getVariable ["REB_var_rebRange", -1];
		// 	_strongest = _x;
		// } forEach REB_itemRebsClasses;

		PR _rebsSorted = ([
			_rebsInContainer, 
			[], 
			{GET_HASH_VAL(GET_HASH(_x), "REB_var_rebRange", 0)}, 
			"DESCEND", 
			{GET_HASH_VAL(GET_HASH(_x), "REB_var_hasActiveReb", false)}
		] call BIS_fnc_sortBy);

		if (count _rebsSorted == 0) exitWith {false};

		PR _rebItem = _rebsSorted#0;

		if !(_rebItem in _allContainerItems) exitWIth {false};

		// [
		// 	_container, 
		// 	HGVAR "REB_var_rebRange", 
		// 	HGVAR "REB_var_rebDeadzone", 
		// 	HGVAR "REB_var_rebStrength", 
		// 	HGVAR "REB_var_hasActiveReb"
		// ] call REB_fnc_reb;
		[_container, _rebItem] call REB_fnc_setRebToObj;
		_container setVariable ["REB_var_currentRebItem", _rebItem, true];
		true
	} else {
		if (_container in REB_all_rebs) then {
			// [_container] call REB_fnc_removeReb;
			[_container, objNull] call REB_fnc_setRebToObj;
		};
		_container setVariable ["REB_var_currentRebItem", nil, true];
		false
	};
};
REB_fnc_rebItemHandle = {
	//check unit inventory and _container if its replaced
	params ["_isTake", "_args"];
	_args params ["_unit", "_container", "_item"];

	[_container] call REB_fnc_handleContainer;

	if (_isTake && (H_PREF(_item) in REB_itemRebsClasses)) then {
		_unit setVariable ["REB_var_currentRebItem", _item, true];

		// PR _namespace = REB_itemRebsClasses get _item;
		// [
		// 	_unit, 
		// 	HGVAR "REB_var_rebRange", 
		// 	HGVAR "REB_var_rebDeadzone", 
		// 	HGVAR "REB_var_rebStrength", 
		// 	HGVAR "REB_var_hasActiveReb"
		// ] call REB_fnc_reb;
		[_unit, _item] call REB_fnc_setRebToObj;
	} else {
		if (_unit in REB_all_rebs) then {[_unit, objNull] call REB_fnc_setRebToObj};
		_unit setVariable ["REB_var_currentRebItem", nil, true];
	};
};
REB_fnc_setActionText = {
	params["_reb", "_text"];

	if (_reb isEqualTo player) then {
		format["Self: %1", _text]
	} else {
		_text
	};
};
REB_fnc_setActions = {
	params["_obj"];

	PR _actionDistance = _obj getVariable ["REB_actionDistance", MGVAR ["REB_global_actionDistance", 2]];

	if !((_obj getVariable ["REB_KILLED_EH", ""]) isEqualType 1) then {
		private _eh = _obj addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];

			[_unit, true] call REB_fnc_removeReb;
			
			private _type = toLower (typeOf _unit);

			if (("volnorez" in _type) || ("sania" in _type)) then {
				deleteVehicle _unit;
			};
		}];

		_obj setVariable ["REB_KILLED_EH", _eh];
	};

	if !((_obj getVariable ["REB_TOGGLE_REB_ACTION_ID", ""]) isEqualType 1) then {
		private _id = _obj addAction
		[
			[_obj, if !(GET_HASH_VAL(_obj, "REB_var_hasActiveReb", false)) then {LOC "$STR_REB_ENABLE"} else {LOC "$STR_REB_DISABLE"}] call REB_fnc_setActionText,
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

	if !((_obj getVariable ["REB_DELETED_EH", ""]) isEqualType 1) then {
		private _eh = _obj addEventHandler ["Deleted", {
			params ["_entity"];
			[_entity, true] call REB_fnc_removeReb;
		}];
		_obj setVariable ["REB_DELETED_EH", _eh];
	};
};
REB_fnc_removeActions = {
	params["_obj"];
	_obj removeAction (_obj getVariable ["REB_TOGGLE_REB_ACTION_ID", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_RANGE_ACTION_ID", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_STRENGHT_ACTION_ID", -1]);
	// _obj removeEventHandler ["Killed", (_obj setVariable ["REB_TOGGLE_REB_ACTION_ID", -1])];

	_obj setVariable ["REB_TOGGLE_REB_ACTION_ID", nil];
	_obj setVariable ["REB_SET_RANGE_ACTION_ID", nil];
	_obj setVariable ["REB_SET_STRENGHT_ACTION_ID", nil];
	// _obj setVariable ["REB_KILLED_EH", nil];
};

REB_fnc_initHash = {
	params[
		"_initObj", 
		["_radius", 100], 
		["_deadzone", 30], 
		["_strenght", 0.5],
		["_active", true],
		["_override", false]
	];

	_strenght = (_strenght max 0) min 1;
	_deadzone = _radius min _deadzone;

	PR _newHashName = HASH_PREF +
	(if (IS_STR(_initObj)) then {
		_initObj
	} else {
		hashValue _initObj;
	});

	PR _newHash = missionNamespace getVariable [_newHashName, createHashMap];

	_newHash set ["HASH_VAR_NAME", _newHashName, _override];
	_newHash set ["HASH_INIT_OBJ", _initObj, _override];
	_newHash set ["REB_var_rebMaxRange", _radius, _override];
	_newHash set ["REB_var_rebMaxDeadzone", _deadzone, _override];
	_newHash set ["REB_var_rebMaxStrength", _strenght, _override];
	_newHash set ["REB_var_rebRatio", (_radius / _deadzone), _override];

	_newHash set ["REB_var_hasActiveReb", _active];
	_newHash set ["REB_var_rebRange", _radius];
	_newHash set ["REB_var_rebDeadzone", _deadzone];
	_newHash set ["REB_var_rebStrength", _strenght];
	if (IS_OBJ(_initObj)) then {
		_newHash set ["HASH_CURRENT_OBJ", _initObj];
	};

	missionNamespace setVariable [_newHashName, _newHash, true];

	if (_override) exitWith {_newHash};

	REB_all_hashes set [_newHashName, compile _newHashName];
	missionNamespace setVariable ["REB_all_hashes", REB_all_hashes, true];

	_newHash
};
REB_fnc_getProperty = {
	params["_obj", ["_prop", ""], ["_def", ""]];

	if !(IS_STR(_prop)) exitWith {_def};
	if (STR_EMPTY(_prop)) exitWith {_def};

	PR _hash = [_obj] call REB_fnc_getObjHash;
	if !(IS_HASH(_hash)) exitWith {_def};

	_hash getDef [_prop, _def];
};
REB_fnc_setProperty = {
	params["_obj", ["_prop", -1], ["_val", 0]];

	if !(_prop isEqualTo "") exitWith {};

	PR _hash = [_obj] call REB_fnc_getObjHash;
	if !(IS_HASH(_hash)) exitWith {""};

	_hash set [_prop, _val];
	UPD_HASH(_hash)
};
REB_fnc_getObjHash = {
	params["_o", ["_getName", false]];

	if (IS_HASH(_o)) exitWith {
		if (_getName) exitWith {HASH_NAME(_o)};
		if (HASH_NAME(_o) in REB_all_hashes) exitWith {_o};
		0
	};
	if (IS_STR(_o)) exitWith {
		[_o, _getName] call REB_fnc_getHash;
	};

	PR _hash = IF_ELSE(IS_HASH(_o), _o, OBJ_CURR_HASH(_o));

	if !(IS_HASH(_hash)) exitWith {0};
	if (_getName) exitWith {HASH_NAME(_hash)};
	
	_hash
};
REB_fnc_getHash = {
	params["_o", ["_getName", false]];

	PR _hashName = 
	if (IS_STR(_o)) then {
		if (HASH_PREF in _o) then {
			_o
		} else {
			HASH_PREF + _o
		}
	} else {
		HASH_PREF + hashValue _o;
	};

	if (_getName) exitWith {_hashName};

	missionNamespace getVariable [_hashName, 0];
};
REB_fnc_removeHash = {
	params["_o"];

	PR _hashName = [_o, true] call REB_fnc_getHash;
	PR _hash = [_o] call REB_fnc_getHash;

	if !(IS_STR(_hashName)) exitWith {};
	if !(IS_HASH(_hash)) exitWith {};

	missionNamespace setVariable [_hashName, nil, true];
	REB_all_hashes deleteAt _hashName;
	missionNamespace setVariable ["REB_all_hashes", REB_all_hashes, true];
	
	(_hash getOrDefault [HASH_INIT_OBJ, objNull]) setVariable ["REB_currentRebHash", nil];
};

// precompile
PR _final = false;
REB_fnc_reb = compileScript ["VTG_REB\functions\fn_reb.sqf", _final];
REB_fnc_removeReb = compileScript ["VTG_REB\functions\fn_removeReb.sqf", _final];
REB_fnc_setRange = compileScript ["VTG_REB\functions\fn_setRange.sqf", _final];
REB_fnc_setStrenght = compileScript ["VTG_REB\functions\fn_setStrenght.sqf", _final];
