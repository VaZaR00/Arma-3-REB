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

	if !(MGVAR ["REB_systemIsOn", true]) exitWith {};

	REB_noise ppEffectEnable false;
	REB_isSuppressed = false;
	call REB_fnc_removeInputDelay;

	_uav = if (!(_newCameraOn isEqualTo player) && (_newCameraOn in allUnitsUAV) && !(_newCameraOn in allPlayers) && (alive player)) then {_newCameraOn} else {objNull};
	REB_currentUAV = _uav;

	if (!(_uav isEqualTo objNull)) exitWith {
		REB_main_handler = [] spawn {
			while {
				uiSleep REB_freq; 
				(alive player) && 
				{(REB_currentUAV isEqualTo (getConnectedUAV player)) && 
				{!(REB_currentUAV isEqualTo objNull)}}
			} do {
				call REB_fnc_main;
			};
			REB_currentUAV = objNull;
		};
	};
};
REB_fnc_main = {
	params [["_freq", REB_freq], ["_random", REB_random], ["_noise", REB_noise], ["_uav", GET_PLAYER_DRONE]];

	REB_isSuppressed = false;
	_noise ppEffectEnable false; 
	call REB_fnc_removeInputDelay;

	if !(MGVAR ["REB_systemIsOn", true]) exitWith {};
	if (_uav getVariable ["REB_var_skipThis", false]) exitWith {};

	if (_uav getVariable ['ArmaFPV_EnableTI', false]) then {
		_uav disableTIEquipment false;
	};
	
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

	if !(_activeRebStrength > 0) exitWith {};

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
			PR _hashVal = _x;
			PR _stren = _obj GV [OBJ_VARPREF("Strenght"), 0];
			if (
				(_d < (_obj GV [OBJ_VARPREF("Range"), -1])) &&
				(_obj GV [OBJ_VARPREF("Is_active"), false]) &&
				(_stren > _currentStrength)
			) then {
				_currentStrength = _stren;
			};
		};
	};

	REB_currentStrength = if (_currentStrength <= 0) then {
		0
	} else {
		_currentStrength
	};
	REB_currentStrength
};
REB_fnc_isInDeadzone = {
	PR _isDead = false;

	REB_all_rebs apply {
		PR _obj = _y;
		PR _d = (_this distance _obj);
		OBJ_REBS_LIST(_obj) apply {
			PR _hashVal = _x;
			PR _stren = _obj GV [OBJ_VARPREF("Strenght"), 0];
			if (
				(_d < (_obj GV [OBJ_VARPREF("Deadzone"), -1])) &&
				(_obj GV [OBJ_VARPREF("Is_active"), false])
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
	_this remoteExec ["deleteVehicleCrew", 0];
	_this spawn {
		uiSleep REB_createUavCrewOnDisconectTime;
		_this remoteExec ["createVehicleCrew", 0];
	};
};
REB_fnc_suppress = {
	REB_isSuppressed = true;

	if (MGVAR ["REB_delayInput", true]) then {
		call REB_fnc_delayInput;
	};

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

	REB_systemIsOn = false;

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
	Delay input simulation system
*/
REB_fnc_delayInput = {
	PR _currentStrength = (missionNamespace getVariable ["REB_currentStrength", 0]);
	PR _chance = _currentStrength * REB_randomDelayInput;

	if ([true, false] selectRandomWeighted [1 - _chance, _chance]) then {
		call REB_fnc_createInputBlockDisplay
	};
};
REB_fnc_removeInputDelay = {
	call REB_fnc_removeInputBlockDisplay
};
// Block mouse and some keys
REB_fnc_createInputBlockDisplay = {
	if !(isNull (uiNamespace getVariable ["REB_tempBlockInputDisp", displayNull])) exitWith {};
	PR _tempBlockInputDisp = findDisplay 46 createDisplay "RscDisplayEmpty";
	uiNamespace setVariable ["REB_tempBlockInputDisp", _tempBlockInputDisp];
	hint ("DELAY INPUT " + str (time));	
	ENSURE_SPAWN_ONCE_START
		hint ("START DELAY INPUT " + str (time));
		PR _currentStrength = (missionNamespace getVariable ["REB_currentStrength", 0]);

		sleep (_currentStrength + (random REB_randomDelayInput));
		hint ("END DELAY INPUT " + str (time));

		call REB_fnc_removeInputDelay;
	ENSURE_SPAWN_ONCE_END
};
REB_fnc_removeInputBlockDisplay = {
	(uiNamespace getVariable ["REB_tempBlockInputDisp", displayNull]) closeDisplay 1;
	uiNamespace setVariable ["REB_tempBlockInputDisp", nil];
};
// Block all keys
REB_fnc_delayInputEventHandler = {
	waitUntil {!isNull findDisplay 46};

	findDisplay 46 displayAddEventHandler ["KeyDown", {
		call REB_fnc_delayInputKeys;
	}];
};
REB_fnc_delayInputKeys = {
	private _handled = false;
	if (
		!((missionNamespace getVariable ["REB_currentUAV", objNull]) isEqualTo objNull) && // does player control drone ?
		(missionNamespace getVariable ["REB_isSuppressed", false])
	) then {
		PR _currentStrength = (missionNamespace getVariable ["REB_currentStrength", 0]);
		PR _chance = _currentStrength * REB_randomDelayInput;

		if (
			([true, false] selectRandomWeighted [1 - _chance, _chance]) &&
			{
				!(inputAction "nextAction" > 0) && 
				!(inputAction "prevAction" > 0) && 
				!(inputAction "Action" > 0) && 
				!(inputAction "ActionContext" > 0) && 
				!(inputAction "navigateMenu" > 0) && 
				!(inputAction "closeContext" > 0) && 
				!(inputAction "ingamePause" > 0) && 
				!(inputAction "uavViewToggle" > 0) && 
				!(inputAction "uavView" > 0)
			}
		) then {
			hint ("KEY DELAY INPUT " + str (time));
			_handled = true; // make delay input
		};
	};

	_handled;
};

/*
	Handle objects functions
*/
REB_fnc_addRebOnObj = {
	if (IS_ARR(_this select 1)) then {
		_this = [_this#0, _this#1#0, _this#1#1];
	};

	params['_obj', '_rebObj', ['_itemRef', objNull]];

	ARGS [_obj I _itemRef];
	PR _rebInst = GET_REB_INSTANCE(_rebObj);

	METHOD_GLOBAL(_rebInst, "New_object_reb", _args);
};
REB_fnc_removeRebOnObj = {
	if (IS_ARR(_this select 1)) then {
		_this = [_this#0, _this#1#0, _this#1#1];
	};

	params['_obj', '_rebObj', ['_itemRef', objNull]];

	ARGS [_obj I _itemRef];
	PR _rebInst = GET_REB_INSTANCE(_rebObj);

	METHOD_GLOBAL(_rebInst, "Delete_object_reb", _args);
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
REB_fnc_setActive = {
	params["_obj", ["_isActive", true], ["_ref", ""], ["_itemRef", 0]];

	private _objectReb = _obj;
	if !(IS_OOP(_objectReb)) then {
		_objectReb = [_obj, _ref, _itemRef] call REB_fnc_getObjectRebByRef;
	};

	if (ISNIL(_objectReb) || {!(IS_OOP(_objectReb))}) exitWith {};

	_obj = INSTANCE_VAR(_objectReb, "Object");

	if (_ref isEqualTo true) exitWith {
		{
			METHOD(OBJ_REB(_x), "Set_Active", _isActive);
		} forEach OBJ_REBS_LIST(_obj);
	};

	METHOD(_objectReb, "Set_Active", _isActive);
};

/*
	Misc functions
*/
REB_fnc_isReb = {
	if (ARR_EMPTY(OBJ_REBS_LIST(_this))) EW {false};

	true
};
REB_fnc_makeRebClassname = {
	if (IS_STR(_this) && {PREF_CLAS in _this}) EW {_this};

	PREF_CLAS +
	(if (IS_STR(_this)) then {
		_this
	} else {
		OBJ_HASHVAL(_this);
	});
};
REB_fnc_rebsInDroneRadius = {
	params["_drone", ["_byRange", true]];
	PR _varRange = if (_byRange) then {"Range"} else {"Deadzone"};
	(values REB_all_rebs) select {
		PR _obj = _x;
		PR _d = (_drone distance _obj);
		count (OBJ_REBS_LIST(_obj) select {
			PR _hashVal = _x;
			(
				(_d < (_obj GV [OBJ_VARPREF(_varRange), -1])) &&
				(_obj GV [OBJ_VARPREF("Is_active"), false])
			)
		}) > 0;
	};
};
REB_fnc_getObjectRebByRef = {
	METHOD(IOO_OBJECT_REB_DB, "Get_object_reb", _this);
};

/*
	Item handling functions
*/
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