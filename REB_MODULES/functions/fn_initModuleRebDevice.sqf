#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};
if !(isServer) exitWith {};

[_logic] spawn {
	params["_logic"];

	private _syncedObj = (synchronizedObjects _logic)#0;

	if (isNil "_syncedObj") then {
		_syncedObj = objNull;
	};

	sleep 0.1;

	private _object = (LGVAR ["Object", ""]);
	if (_object isEqualType "") then {
		_object = call compile _object;
	};
	private _linkedObjects = ((LGVAR ["linkedObjects", ""]) splitString ";., ") apply {MGVAR [_x, objNull]};

	if ((isNil "_object") || {!(_object isEqualType objNull)}) then {
		_object = _syncedObj;
	};

	if ((isNil "_object") || {(_object isEqualTo objNull)}) exitWith {};

	[
		_object,
		LGVAR ["Radius", 100],
		LGVAR ["Deadzone", 30],
		LGVAR ["Strength", 0.5],
		BOOL("IsAttachable", 0),
		BOOL("CanModifyRange", 1),
		BOOL("CanModifyStrength", 0),
		BOOL("IsActive", 1),
		BOOL("SimulateDamage", 0),
		LGVAR ["SimulatedHealth", 100],
		_linkedObjects,
		BOOL("ActionsOnlyForCrew", 1)
	] spawn REB_fnc_reb;
};

