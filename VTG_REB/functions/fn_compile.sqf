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
	PR _sortedByStrenght = [_this, [], { (GET_HASHS_OBJ_VAL(GET_HASH(_x), "REB_var_rebStrength", 0, _x)) }, "DESCEND"] call BIS_fnc_sortBy; 

	PR _activeReb = _sortedByStrenght#0;
	PR _strenght = GET_HASHS_OBJ_VAL(GET_HASH(_activeReb), "REB_var_rebStrength", 0, _activeReb) ^ (1 / (count _sortedByStrenght));
	
	PR _effect = (random _random) * _strenght;
	
	_effect call REB_fnc_showEffect;
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

	if (_hasSet) exitWith {true};

	if (_container in REB_all_rebs) then {
		// [_container] call REB_fnc_removeReb;
		[_container, objNull] call REB_fnc_setRebToObj;
	};
	_container setVariable ["REB_var_currentRebItem", nil, true];

	false
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
			_items = keys REB_all_hashes;
		} else {
			_items = [_items];
		};
	};

	(allUnits + vehicles + ("GroundWeaponHolder" allObjects 0)) apply {
		_o = _x;
		// IF_(!ISNIL(_o GV "REB_var_hasActiveReb"), SKIP);
		{
			if ([_o, _x] call REB_fnc_handleContainer) EX;
		} forEach _items;
	};
	REB_initingRebItems = nil;
};
REB_fnc_setRebToObj = {
	params["_newObj", ["_reb", objNull]];

	PR _hash = [_reb] call REB_fnc_getObjHash;
	PR _currentHash = OBJ_CURR_HASH(_newObj);

	if (_hash isEqualTo _currentHash) exitWith {};

	if (IS_HASH(_currentHash)) then {
		[_currentHash, _newObj, false] call REB_fnc_handleHashObj;
	};
	if !(IS_HASH(_hash)) exitWith {
		// removing
		_newObj setVariable ["REB_currentRebHash", nil, true];
		_newObj remoteExec ["REB_fnc_removeActions", 0];
		[_newObj] call REB_fnc_updateAllRebsArr;
	};

	// setting
	_newObj setVariable ["REB_currentRebHash", compile HASH_NAME(_hash), true];
	
	[_hash, _newObj] call REB_fnc_handleHashObj;

	_newObj remoteExec ["REB_fnc_setActions", 0];
	_newObj remoteExec ["REB_fnc_setEventHandlers", 0];

	[_newObj] call REB_fnc_updateAllRebsArr;
};
REB_fnc_changeRebOnObj = {
	params["_obj", "_new", ["_prevObj", objNull]];

	PR _newHash = GET_HASH(_new);
	PR _oldHash = GET_HASH(_obj);

	if (_newHash isEqualTo _oldHash) exitWith {};
	if (!IS_HASH(_newHash)) exitWith {};

	if (IS_HASH(_oldHash)) exitWith {
		if (GET_HASHS_OBJ_VAL(_oldHash, "REB_var_rebRange", 0, _obj) < GET_HASHS_OBJ_VAL(_newHash, "REB_var_rebRange", 0, _new)) then {
			[_obj, _newHash] call REB_fnc_setRebToObj;
			[_newHash, HAS_ACTIVE_REB_TRUE(_prevObj), _obj] call REB_fnc_setRebActive;
		};
	};
	[_obj, _newHash] call REB_fnc_setRebToObj;	
	[_newHash, HAS_ACTIVE_REB_TRUE(_prevObj), _obj] call REB_fnc_setRebActive;
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
REB_fnc_setRebObjValues = {
	params ["_obj", ["_args", []]];
	_args params [["_active", nil], ["_radius", nil], ["_deadzone", nil], ["_strenght", nil]];

	IF_EX(!IS_OBJ(_obj));

	PR _hash = GET_HASH(_obj);

	SET_HASHS_OBJ_VAL(_hash, "REB_var_hasActiveReb", NIL_(_active), _obj);
	SET_HASHS_OBJ_VAL(_hash, "REB_var_rebRange", NIL_(_radius), _obj);
	SET_HASHS_OBJ_VAL(_hash, "REB_var_rebDeadzone", NIL_(_deadzone), _obj);
	SET_HASHS_OBJ_VAL(_hash, "REB_var_rebStrength", NIL_(_strenght), _obj);
};
REB_fnc_handleHashObj = {
	params["_hash", "_obj", ["_add", true]];

	if (!(IS_HASH(_hash)) || !(IS_OBJ(_obj))) exitWith {};

	PR _currObjs = GET_HASH_OBJS(_hash);

	if (IS_ARR(_currObjs)) then {
		PR _i = _currObjs find _obj;
		if (_add) then {
			IF_((_i == -1), (_currObjs pushBack _obj));
		} else {
			IF_((_i != -1), (_currObjs deleteAt _i));
		};
	} else {
		_currObjs = IF_ELSE(_add, [_obj], []);
	};

	_hash set ["HASH_CURRENT_OBJS", _currObjs];
	UPD_HASH(_hash);

	if (_add) then {
		[_obj, [true, HASH_MAXRANGE(_hash), HASH_MAXDEADZ(_hash), HASH_MAXSTREN(_hash)]] call REB_fnc_setRebObjValues;
	} else {
		[_obj] call REB_fnc_setRebObjValues;
	};
};

REB_fnc_setRebActive = {
	params[["_reb", ""], ["_state", true], ["_obj", []]];

	R_HASH(_reb);

	IF_(!IS_ARR(_obj), _obj = [_obj]);
	IF_(ARR_EMPTY(_obj), _obj = GET_HASH_OBJS(_reb));

	{
		SET_HASHS_OBJ_VAL(_reb, "REB_var_hasActiveReb", _state, _x)
	} forEach _obj;
};
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
			
			private _type = toLower (typeOf _unit);

			// if (("volnorez" in _type) || ("sania" in _type)) then {
			// 	[_unit] spawn REB_fnc_destructionEffect;
			// };
		}];

		_obj setVariable ["REB_KILLED_EH", _eh];
	};
};
REB_fnc_removeActions = {
	params["_obj"];

	if !(IS_OBJ(_obj)) exitWith {};

	_obj removeAction (_obj getVariable ["REB_TOGGLE_REB_ACTION_ID", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_RANGE_ACTION_ID", -1]);
	_obj removeAction (_obj getVariable ["REB_SET_STRENGHT_ACTION_ID", -1]);

	_obj setVariable ["REB_TOGGLE_REB_ACTION_ID", nil];
	_obj setVariable ["REB_SET_RANGE_ACTION_ID", nil];
	_obj setVariable ["REB_SET_STRENGHT_ACTION_ID", nil];
};
REB_fnc_removeEventHandlers = {
	params[["_obj", 0]];

	if !(IS_OBJ(_obj)) exitWith {};

	_obj removeEventHandler ["Deleted", (_obj getVariable ["REB_DELETED_EH", -1])];
	_obj removeEventHandler ["Killed", (_obj getVariable ["REB_KILLED_EH", -1])];

	_obj setVariable ["REB_DELETED_EH", nil];
	_obj setVariable ["REB_KILLED_EH", nil];
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
	_newHash set ["REB_var_rebIsOn", _active, _override];

	if (IS_OBJ(_initObj)) then {
		[_newHash, _initObj] call REB_fnc_handleHashObj;
	};

	REB_all_hashes set [_newHashName, compile _newHashName];
	MSVAR ["REB_all_hashes", REB_all_hashes, true];

	MSVAR [_newHashName, _newHash, true];

	[_initObj, [_active, _radius, _deadzone, _strenght]] call REB_fnc_setRebObjValues;

	// if (_override) exitWith {_newHash};

	_newHash
};
REB_fnc_getProperty = {
	params["_obj", ["_prop", ""], ["_def", ""], ["_hashObj", objNull]];

	if !(IS_STR(_prop)) exitWith {_def};
	if (STR_EMPTY(_prop)) exitWith {_def};

	PR _hash = [_obj] call REB_fnc_getObjHash;
	if !(IS_HASH(_hash)) exitWith {_def};

	if !(IS_OBJ(_hashObj) && {!IS_OBJNULL(_hashObj)}) then {
		_hash getDef [_prop, _def];
	} else {
		PR _currObjs = GET_HASH_OBJS(_hash);

		IF_EXW(!(_hashObj in _currObjs), _def);

		_hashObj GV [_prop, _def];
	};
};
REB_fnc_setProperty = {
	params["_obj", ["_prop", -1], ["_val", nil], ["_hashObj", objNull]];
	
	if (STR_EMPTY(_prop)) exitWith {};
	
	PR _hash = GET_HASH(_obj);
	
	if !(IS_HASH(_hash)) exitWith {};
	
	if !(IS_OBJ(_hashObj) && {!IS_OBJNULL(_hashObj)}) then {
		_hash set [_prop, NIL_(_val)];
		UPD_HASH(_hash)
	} else {
		PR _currObjs = GET_HASH_OBJS(_hash);

		IF_EX(!(_hashObj in _currObjs));

		_hashObj SV [_prop, NIL_(_val), true];
	};
};
REB_fnc_getObjHash = {
	params[["_o", 0], ["_getName", false]];

	if (IS_HASH(_o)) exitWith {
		if (_getName) exitWith {HASH_NAME(_o)};
		if (HASH_NAME(_o) in REB_all_hashes) exitWith {_o};
		0
	};
	if (IS_STR(_o)) exitWith {
		[_o, _getName] call REB_fnc_getHash;
	};

	PR _hash = IF_ELSE((IS_HASH(_o) || !IS_OBJ(_o)), _o, OBJ_CURR_HASH(_o));

	if !(IS_HASH(_hash)) exitWith {0};
	if (_getName) exitWith {HASH_NAME(_hash)};
	
	_hash
};
REB_fnc_getHash = {
	params[["_o", ""], ["_getName", false]];

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

	MSVAR [_hashName, nil, true];
	REB_all_hashes deleteAt _hashName;
	MSVAR ["REB_all_hashes", REB_all_hashes, true];
	
	(_hash getDef [HASH_INIT_OBJ, objNull]) setVariable ["REB_currentRebHash", nil];
};

// precompile
PR _final = false;
REB_fnc_reb = compileScript ["VTG_REB\functions\fn_reb.sqf", _final];
REB_fnc_removeReb = compileScript ["VTG_REB\functions\fn_removeReb.sqf", _final];
REB_fnc_setRange = compileScript ["VTG_REB\functions\fn_setRange.sqf", _final];
REB_fnc_setStrenght = compileScript ["VTG_REB\functions\fn_setStrenght.sqf", _final];
REB_fnc_setValueDialog = compileScript ["VTG_REB\functions\fn_setValueDialog.sqf", _final];
REB_fnc_destructionEffect = compileScript ["VTG_REB\functions\fn_destructionEffect.sqf", _final];

