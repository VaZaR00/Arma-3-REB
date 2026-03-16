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

	// reset effects and vars
	REB_isSuppressed = false;
	_noise ppEffectEnable false; 
	call REB_fnc_removeInputDelay;

	// set TI
	private _hadTI = _uav getVariable ['REB_hadTI', 0];
	if (_hadTI isEqualTo 0) then { // set default TI value
		(equipmentDisabled _uav) params ["_nvg", "_hasTI"];
		_uav setVariable ['REB_hadTI', _hasTI];
	};
	if (_hadTI isEqualTo true) then {
		_uav disableTIEquipment false;
	};

	// check if system is on, if we have drone and if we have any rebs
	if !(MGVAR ["REB_systemIsOn", true]) exitWith {};
	if (_uav getVariable ["REB_var_skipThis", false]) exitWith {};
	if (count REB_all_rebs == 0) exitWith {};

	// check if lancet
	PR _isLancet = ISLANCETHANDL;
	if !((_uav in allUnitsUAV) || _isLancet) exitWith {};
	if (_isLancet) then {
		_uav = uiNamespace getVariable ["lancet_currentProjectile", objNull];
	};

	(_uav call REB_fnc_currentJammingRebStrength) params ["_activeRebStrength", "_activeReb", "_isInDeadZone"];

	if (_isInDeadZone) exitWith {
		_uav call REB_fnc_disconectDrone;
	};

	if !(_activeRebStrength > 0) exitWith {};

	_uav disableTIEquipment true;
	
	if (_isLancet) then {
		false setCamUseTI 0;
	};

	_activeRebStrength call REB_fnc_suppress;
};
REB_fnc_currentJammingRebStrength = {
	private _currentStrength = 0;
	private _isInDeadzone = false;
	private _currentReb = objNull;
	private _initRCoef = MVARDEF(REB_initialInfluenceRadiusCoef, 3);

	REB_all_rebs apply {
		if (_isInDeadzone) exitWith {};
		PR _obj = _y;
		PR _d = (_this distance _obj);
		OBJ_REBS_LIST(_obj) apply {
			if (_isInDeadzone) exitWith {};
			PR _hashVal = _x;
			PR _stren = _obj GV [OBJ_VARPREF("Strenght"), 0];
			PR _range = _obj GV [OBJ_VARPREF("Range"), -1];
			PR _rangeInit = (_range / _initRCoef);
			PR _rangeFull = _range + _rangeInit;
			if (
				(_d < _rangeFull) &&
				{(_obj GV [OBJ_VARPREF("Is_active"), false]) &&
				(_stren > _currentStrength)}
			) then {
				if (_d <= _range) then {
					_currentStrength = _stren;
				} else {
					private _dInInit = _rangeFull - _d;
					private _initDCoef = _dInInit / _rangeInit;
					_currentStrength = _stren * _initDCoef;
					LOG_VARS("INIT RANGE", "_d, _range, _rangeInit, _dInInit, _initDCoef, _stren, _currentStrength");
				};
				_currentReb = _obj;
				private _lineOfSight = _currentStrength;
				private _lineOfSightCalculated = [_currentReb, _this, _currentStrength, _range] call REB_fnc_lineOfSightModifier;
				if !(isNil "_lineOfSightCalculated") then {
					_lineOfSight = _lineOfSightCalculated;
				};
				if (_lineOfSight > 0) then {
					private _strenRatio = _lineOfSight / _currentStrength;
					private _deadzone = (_obj GV [OBJ_VARPREF("Deadzone"), -1]);
					private _deadZoneRatioed = _deadzone * _strenRatio;
					_currentStrength = _lineOfSight;
					if (_d < _deadZoneRatioed) exitWith {
						_isInDeadzone = true;
					};
				} else {
					_currentStrength = 0;
					_currentReb = objNull;
				};
			};
		};
	};

	REB_currentStrength = if (_currentStrength <= 0) then {
		0
	} else {
		_currentStrength
	};
	[REB_currentStrength, _currentReb, _isInDeadzone]
};
REB_fnc_getRebEmitPoint = {
	// get relative point where reb effect should be emitted from
	params ["_reb"];

	private _typeOf = typeOf _reb;
	private _customSettings = MGVAR ["REB_customRebEmitSettings", createHashMap];

	_customSettings getOrDefault [_typeOf, [0,0,0.3]] // default point is 30cm above center of object;
};
REB_fnc_getObjectModifier = {
	params ["_obj", ["_mod", 1]];

	private _modelInfo = getModelInfo _obj;
	private _p3dPath = _modelInfo select 1;
	private _modifier = 0;

	_modifier = _obj call {
		if (_obj isKindOf "Tank") exitWith {0.7};
		if (_obj isKindOf "LandVehicle") exitWith {0.5};
		0
	};

	if (_modifier == 0) then {
		_modifier = _p3dPath call {
			if ("bush" in _this) exitWith {0.1};
			if ("tree" in _this) exitWith {0.1};
			if ("office" in _this) exitWith {0.7};
			if ("build" in _this) exitWith {0.6};
			if ("house" in _this) exitWith {0.6};
			if ("trench" in _this) exitWith {0.6};
			if ("okop" in _this) exitWith {0.6};
			if ("metal" in _this) exitWith {0.7};
			if ("wall" in _this) exitWith {0.4};
			if ("fence" in _this) exitWith {0.3};
			0
		};
	};
	_modifier = _modifier * _mod;
	private _result = 1 - _modifier;
	_result = _result max 0;
	_result = _result min 1;
	_result
};
REB_fnc_lineOfSightModifier = {
	params [["_reb", objNull], ["_uav", objNull], ["_baseStrength", 0.5], ["_rebRange", 50]];

	private _uavPos = getPosASL _uav;
	private _rebPos = getPosASL _reb;
	private _rebEmitPoint = _reb call REB_fnc_getRebEmitPoint;
	private _correctedRebPos = _rebPos vectorAdd _rebEmitPoint;
	private _dist = _uav distance _reb;
	private _distMod = _dist / _rebRange;

	private _finalStrength = _baseStrength;

	// check terrain intersection
	private _interstectsTerrain = terrainIntersectASL [_uavPos, _rebPos];
	if (_interstectsTerrain) then {
		_finalStrength = _finalStrength * MVARDEF(REB_terrainInterstectStrengthCoef, 0.5);
	};

	// check straight line of sight between reb and drone
	private _interstectsStraight1 = lineIntersectsObjs [_correctedRebPos, _uavPos, _uav, objNull, true];
	private _interstects1Count = count _interstectsStraight1;
	private _interstectsAboveCount = 0;
	if (_interstects1Count > 0) then {
		private _firstIntersectStraight1 = _interstectsStraight1#0;

		// check if reb is covered by something from above
		private _posAboveReb = _correctedRebPos vectorAdd [0,0,20];
		private _interstectsAbove = lineIntersectsObjs [_correctedRebPos, _posAboveReb, _uav, objNull, true];
		_interstectsAboveCount = count _interstectsAbove;

		if (_interstectsAboveCount > 0) then {
			private _firstIntersectAbove = _interstectsAbove#0;
			private _objectAboveModifier = [_firstIntersectStraight1, _distMod] call REB_fnc_getObjectModifier;
			private _isSameObjs = _firstIntersectStraight1 isEqualTo _firstIntersectAbove;

			if (_isSameObjs && {(_interstectsAboveCount == 1) && (_interstects1Count == 1)}) exitWith {};

			if (_isSameObjs) then {
				if (_objectAboveModifier > 0.5) then {
					// if line of sight and above reb is same object and modifier is high we count it as reb is in building fully covered
					_finalStrength = _finalStrength * MVARDEF(REB_coveredRebStrengthModifier, 0.7);
				};
			};
			_finalStrength = _finalStrength * (_objectAboveModifier);
		};

		if (_finalStrength < MVARDEF(REB_minRebStrength, 0.05)) exitWith {
			_finalStrength = 0;
		}; 

		{
			private _objectModifier = [_x, _distMod] call REB_fnc_getObjectModifier;
			_finalStrength = _finalStrength * (_objectModifier);
			if (_finalStrength < MVARDEF(REB_minRebStrength, 0.05)) exitWith {
				_finalStrength = 0;
			}; 
		} forEach _interstectsStraight1;
	} else {
		// if we have straight line of sight - full effect
		_finalStrength = _baseStrength;
	};

	// hintSilent format ["STR: %1; INTERSECTS: %2; ABOVE: %3; MODS: %4", _finalStrength, _interstects1Count, _interstectsAboveCount, (_interstectsStraight1 apply {[_x, ([_x, _distMod] call REB_fnc_getObjectModifier), getModelInfo _x]})];

	_finalStrength
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
	PR _chance = _currentStrength * REB_delayInputCoef * (MGVAR ["REB_mouseDelayInputCoef", 1]);

	if ([true, false] selectRandomWeighted [1 - _chance, _chance]) then {
		call REB_fnc_createInputBlockDisplay
	};
};
REB_fnc_removeInputDelay = {
	DB_inputDelayed = false;
	call REB_fnc_removeInputBlockDisplay;
};
// Block mouse and some keys
REB_fnc_createInputBlockDisplay = {
	if (dialog) exitWith {};
	createDialog ["RscDisplayEmpty", false];
	ENSURE_SPAWN_ONCE_START
		PR _currentStrength = (missionNamespace getVariable ["REB_currentStrength", 0]);

		[] spawn {
			while {dialog && (MGVAR ["DB_inputDelayed", false])} do {
				setMousePosition [100,100];
			};
		};

		sleep (_currentStrength + (random REB_delayInputCoef));

		call REB_fnc_removeInputDelay;
	ENSURE_SPAWN_ONCE_END
};
REB_fnc_removeInputBlockDisplay = {
	closeDialog 1;
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
	PR _currentStrength = (missionNamespace getVariable ["DB_currentSignal", 0]);

	if (
		!((missionNamespace getVariable ["ArmaFPV_currentUAV", objNull]) isEqualTo objNull) &&
		{(_currentStrength < (MGVAR ["ArmaFPV_delayInputThreashold", 0.3])) &&
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
		}}
	) then {
		_handled = true; // make delay input
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

// Damage simulation system
REB_fnc_onHit = {
	(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect", "_instigator"];
	_ammo params ["_hitVal", "_indirectHitVal", "_indirectHitRange", "_explosiveDamage", "_ammoClass"];

	[_target, _hitVal] call REB_fnc_handleDamage;
};
REB_fnc_onExplosion = {
	params ["_vehicle", "_damage", "_explosionSource"];

	private _distance = if (_explosionSource isEqualTo objNull) then {1} else {_vehicle distance _explosionSource};
	_distance = _distance min 20;
	private _hit = getNumber (configFile >> "CfgAmmo" >> typeOf _explosionSource >> "hit");
	private _damage = _hit / (_distance max 1); // avoid div by 0

	[_vehicle, _damage] call REB_fnc_handleDamage;
};
REB_fnc_handleDamage = {
	params ["_obj", "_damage"];

	if !(alive _obj) exitWith {};
	if !(_obj GV ["REB_var_SimulateDamage", true]) exitWith {};

	PR _varName = "REB_object_var_simulatedHealth";
	PR _maxVal = _obj GV ["REB_object_var_maxSimulatedHealth", 100];
	PR _currentVal = _obj GV [_varName, 100];
	PR _newVal = _currentVal - _damage;

	_obj setVariable [_varName, _newVal, true];

	private _damage = 1 - (_newVal/_maxVal);

	_obj setDamage _damage;

	if (_damage >= 1) then {
		[_obj, true] call REB_fnc_removeReb;
	};
};
REB_fnc_simulateDamage = {
	// should be executed on every client
	params["_obj", ["_simulateDamage", false], ["_health", 100]];

	if !(IS_OBJ(_obj)) exitWith {};

	if (_simulateDamage) then {
		if !((_obj getVariable ["REB_HIT_EH", ""]) isEqualType 1) then {
			private _eh = _obj addEventHandler ["HitPart", {call REB_fnc_onHit}];

			_obj setVariable ["REB_HIT_EH", _eh];
		};
		if !((_obj getVariable ["REB_EXPL_EH", ""]) isEqualType 1) then {
			private _eh = _obj addEventHandler ["Explosion", {call REB_fnc_onExplosion}];

			_obj setVariable ["REB_EXPL_EH", _eh];
		};
	};

	if (local _obj) then {
		_obj setVariable ["REB_object_var_simulatedHealth", _health, true];
		_obj setVariable ["REB_object_var_maxSimulatedHealth", _health, true];
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