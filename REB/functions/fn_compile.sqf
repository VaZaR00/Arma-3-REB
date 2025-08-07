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
REB_fnc_initEffects = {
	if !(hasInterface) exitWith {};

	REB_noise = ppEffectCreate ["FilmGrain",3000];
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
		REB_main_handler = [] spawn {
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
	// disables REB system localy

	(values REB_all_rebs) apply {
		[_x] call REB_fnc_removeEventHandlers;
		[_x] call REB_fnc_objectRemoveAllRebAceActions;
	};
	if !(isNil "REB_ON_HANDLE_DRONE_EH") then {
		removeMissionEventHandler ["PlayerViewChanged", REB_ON_HANDLE_DRONE_EH];
	};
	if !(isNil "REB_noise") then {
		ppEffectDestroy REB_noise;
	};
	if !(isNil "REB_main_handler") then {
		terminate REB_main_handler;
	};

	REB_all_rebs = nil;

	MSVAR ["REB_var_INITED", false];

	hint "REB SYSTEM DISABLED";
};

/*
	Handle objects functions
*/
REB_fnc_addRebOnObj = {
	if (IS_ARR(_this select 1)) then {
		_this = [_this#0, _this#1#0, _this#1#1];
	};

	EXEC_ON_SERVER_START
		params['_obj', '_rebObj', ['_itemRef', objNull]];

		METHOD(GET_REB_INSTANCE(_rebObj), "New_object_reb", [_obj C _itemRef]);
	EXEC_ON_SERVER_END
};
REB_fnc_removeRebOnObj = {
	if (IS_ARR(_this select 1)) then {
		_this = [_this#0, _this#1#0, _this#1#1];
	};

	EXEC_ON_SERVER_START 
		params['_obj', '_rebObj', ['_itemRef', objNull]];

		METHOD(GET_REB_INSTANCE(_rebObj), "Delete_object_reb", [_obj C _itemRef]);
	EXEC_ON_SERVER_END
};
REB_fnc_rebItemHandle = {
	//check unit inventory and _container if its replaced
	
	params ["_isTake", "_args"];
	_args params ["_unit", "_container", "_item"];

	PR _isRebItem = (RC_PREF(_item) in REB_all_classes);
	
	if (_isTake && _isRebItem) EW {
		private _backpackInfo = [backpack player, backpackContainer player];

		if (_item != (_backpackInfo#0)) EX; // we work only with backpacks

		REB_currentPlayerBackpack = _backpackInfo;

		[_unit, _backpackInfo] call REB_fnc_addRebOnObj;
		[_container, _backpackInfo] call REB_fnc_removeRebOnObj;
	};
	[_unit, _container] call REB_fnc_handleContainer;
};
REB_fnc_initRebItemSystem = {
	if (REB_var_rebItemsSystemInited) exitWith {};

	if !((missionNamespace getVariable ["REB_ON_PUT_EH", ""]) isEqualType 1) then {
		REB_ON_PUT_EH = player addEventHandler ["Put", {
			[false, _this] call (REB_fnc_rebItemHandle);
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_TAKE_EH", ""]) isEqualType 1) then {
		REB_ON_TAKE_EH = player addEventHandler ["Take", {
			[true, _this] call (REB_fnc_rebItemHandle);
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_INV_OPEN_EH", ""]) isEqualType 1) then {
		REB_ON_INV_OPEN_EH = player addEventHandler ["InventoryOpened", {
			params ["_unit", "_primaryContainer", "_secondaryContainer"];

			if (_primaryContainer isEqualTo _unit) EX;

			REB_TEMP_primaryContainer = _primaryContainer;
			REB_TEMP_secondaryContainer = if 
				(_primaryContainer isEqualTo _secondaryContainer) 
			then {
				objNull
			} else {
				REB_TEMP_secondaryContainer_items = everyBackpack _secondaryContainer;
				_secondaryContainer
			};

			// {
			// 	if !((_x GV ["REB_ON_PUT_EH", ""]) isEqualType 1) then {
			// 		PR _REB_ON_PUT_EH = _x addEventHandler ["Put", {
			// 			[false, _this] call (REB_fnc_rebItemHandle);
			// 		}];
			// 		_x SV ["REB_ON_PUT_EH", _REB_ON_PUT_EH];
			// 	};

			// 	if !((_x GV ["REB_ON_TAKE_EH", ""]) isEqualType 1) then {
			// 		PR _REB_ON_TAKE_EH = _x addEventHandler ["Take", {
			// 			[true, _this] call (REB_fnc_rebItemHandle);
			// 		}];
			// 		_x SV ["REB_ON_TAKE_EH", _REB_ON_TAKE_EH];
			// 	};
			// } forEach [_primaryContainer, _secondaryContainer];
		}];
	};

	if !((missionNamespace getVariable ["REB_ON_INV_CLOSE_EH", ""]) isEqualType 1) then {
		REB_ON_INV_CLOSE_EH = player addEventHandler ["InventoryClosed", {
			params ["_unit", "_container"];

			// fully scan containers only if player have moved items between two containers

			if (
				!(ARR_EMPTY(REB_TEMP_secondaryContainer_items)) && 
				!(REB_TEMP_secondaryContainer_items isEqualTo (everyBackpack REB_TEMP_secondaryContainer))
			) then {
				[_unit, REB_TEMP_primaryContainer] call REB_fnc_handleContainerFull;
				[_unit, REB_TEMP_secondaryContainer] call REB_fnc_handleContainerFull;
			};

			REB_TEMP_primaryContainer = objNull;
			REB_TEMP_secondaryContainer = objNull;
			REB_TEMP_secondaryContainer_items = [];
		}];
	};

	REB_TEMP_primaryContainer = objNull;
	REB_TEMP_secondaryContainer = objNull;
	REB_TEMP_secondaryContainer_items = [];
	REB_currentPlayerBackpack = [];

	if (isServer) then {
		[] SPAWN_F_ONCE(REB_fnc_initRebItems);
	};
	
	REB_var_rebItemsSystemInited = true;
};
REB_fnc_initRebItems = {
	params[["_items", ""]];

	if !(IS_ARR(_items)) then {
		if (STR_EMPTY(_items)) then {
			_items = keys REB_all_classes;
		} else {
			_items = [_items];
		};
	};

	(allUnits + vehicles + ("GroundWeaponHolder" allObjects 0)) apply {
		[_x] call REB_fnc_handleContainerFull
	};
};
REB_fnc_disableRebItemSystem = {
	if !(REB_var_rebItemsSystemInited) exitWith {};

	player removeEventHandler ["Put", MGVAR ["REB_ON_PUT_EH", -1]];
	player removeEventHandler ["Take", MGVAR ["REB_ON_TAKE_EH", -1]];
	player removeEventHandler ["InventoryOpened", MGVAR ["REB_ON_INV_OPEN_EH", -1]];
	player removeEventHandler ["InventoryClosed", MGVAR ["REB_ON_INV_CLOSE_EH", -1]];

	REB_var_rebItemsSystemInited = false;
};
REB_fnc_handleContainer = {
	params["_unit", ["_container", objNull]];

	if (IS_OBJNULL(_container)) EX;

	if ((REB_currentPlayerBackpack in (everyContainer _container)) || {(backpackContainer _container) in REB_currentPlayerBackpack}) EW {
		[_unit, REB_currentPlayerBackpack] call REB_fnc_removeRebOnObj;
		[_container, REB_currentPlayerBackpack] call REB_fnc_addRebOnObj;
		REB_currentPlayerBackpack = [];
	};
};
REB_fnc_handleContainerFull = {
	params["_obj"];

	if (IS_OBJNULL(_obj)) EX;

	private _containersInfo = if (_obj in allUnits) then {[[backpack _obj, backpackContainer _obj]]} else {everyContainer _obj};
	private _containersInfoItemRefs = _containersInfo apply {_x#1};
	OBJ_REBS_LIST_VAR

	{
		if (_y in _containersInfoItemRefs) then {
			[_obj, _obj, _y] call REB_fnc_removeRebOnObj;
		};
	} forEach _objRebs;
	{
		if (RC_PREF((_x select 0)) in REB_all_classes) then {
			[_obj, _x] call REB_fnc_addRebOnObj;
		};
	} forEach _containersInfo;
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
	if (IS_REB(_obj)) exitWith {};

	_obj removeEventHandler ["Deleted", (_obj getVariable ["REB_DELETED_EH", -1])];
	_obj removeEventHandler ["Killed", (_obj getVariable ["REB_KILLED_EH", -1])];
	_obj removeEventHandler ["Killed", (_obj getVariable ["REB_HIT_EH", -1])];

	_obj setVariable ["REB_DELETED_EH", nil];
	_obj setVariable ["REB_KILLED_EH", nil];
	_obj setVariable ["REB_HIT_EH", nil];
};
REB_fnc_objectRemoveAllRebAceActions = {
	params["_object"];

	{
		[_object, _x] call REB_fnc_objectRemoveAceActions;
	} forEach ((allVariables _object) select {"REB_AceActions_" in _x});
};
REB_fnc_simulateDamage = {
	// should be executed on every client
	params["_obj", ["_simulateDamage", false], ["_health", 100]];

	if !(IS_OBJ(_obj)) exitWith {};

	if (_simulateDamage && !((_obj getVariable ["REB_HIT_EH", ""]) isEqualType 1)) then {
		private _eh = _obj addEventHandler ["HitPart", {
			(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect", "_instigator"];
			_ammo params ["_hitVal", "_indirectHitVal", "_indirectHitRange", "_explosiveDamage", "_ammoClass"];

			if !(local _target) exitWith {};
			if !(alive _target) exitWith {};
			if !(_target GV ["REB_var_SimulateDamage", true]) exitWith {};

			PR _varName = "REB_object_var_simulatedHealth";
			PR _newVal = (_target GV [_varName, 100]) - _hitVal;

			_target setVariable [_varName, _newVal, true];

			if (_newVal <= 0) then {
				_target setDamage 1;
			};
		}];

		_obj setVariable ["REB_HIT_EH", _eh];
	};

	if (local _obj) then {
		_obj setVariable ["REB_object_var_simulatedHealth", _health, true];
		_obj setVariable ["REB_var_SimulateDamage", _simulateDamage, true];
	};
};

/*
	Handle REB player actions
*/
REB_fnc_makeAttachable = {
	params[["_obj"]];

	if !(IS_OBJ(_obj)) exitWith {};
	if !(IS_REB(_obj)) exitWith {};

	PR _action = _obj addAction [
		LOC "$STR_REB_ATTACH",
		{
			params ["_target", ["_player", player], ["_params", []]];
			[_target] call REB_fnc_attachReb;
		},
		[],
		0, true, true, "", 
		"true"
	];

	_obj setVariable ["REB_ATTACH_ACTION", _action];
};
REB_fnc_setActive = {
	EXEC_ON_SERVER_START
		params["_object", ["_isActive", true], ["_ref", ""], ["_itemRef", 0]];

		private _objectReb = _object;
		if !(IS_OOP(_objectReb)) then {
			_objectReb = [_object, _ref, _itemRef] call REB_fnc_getObjectRebByRef;
		};

		if (ISNIL(_objectReb) || {!(IS_OOP(_objectReb))}) exitWith {};

		if (_ref isEqualTo true) exitWith {
			{
				METHOD(_x, "Set_Active", _isActive);
			} forEach OBJ_REBS_LIST(_object);
		};

		METHOD(_objectReb, "Set_Active", _isActive);
	EXEC_ON_SERVER_END
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
REB_fnc_getObjectRebByRef = {
	METHOD(IOO_OBJECT_REB_DB, "Get_object_reb", _this);
};