//reb - [object, radius, deadzone, strenght]

// [_this, 100, 30, 0.5] spawn REB_fnc_reb;

#include "defines.h"

sleep 1;
waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

params[
	"_obj", 
	["_range", 100], 
	["_deadzone", 30], 
	["_strenght", 0.6], 
	["_can_modify_range", true], 
	["_can_modify_strenght", true], 
	["_active", true]
];

if !(IS_LOCAL(_obj)) exitWith {};

PR _rebObject = ["new", _this] call OO_REB;

MSVAR [OBJECT_VAR(_rebObject, Name), _rebObject, true];