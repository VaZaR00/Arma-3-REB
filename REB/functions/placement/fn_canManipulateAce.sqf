#include "..\defines.h"

params["_object"];

if (isNull _object) exitWith {};

// add ACE dragging and carrying
if !(_object getVariable ["ace_dragging_candrag", false]) then {
	[_object, true, [0, 1.5, 0], 0, false, true] call ace_dragging_fnc_setDraggable;
};
if !(_object getVariable ["ace_dragging_cancarry", false]) then {
	[_object, true, [0, 1.5, 0], 0, false, true] call ace_dragging_fnc_setCarryable;
};