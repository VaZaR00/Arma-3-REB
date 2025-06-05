//reb - [object, radius, deadzone, strenght]

// [_this, 100, 30, 0.5] spawn REB_fnc_reb;

#include "defines.h"


waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

params[ 
	"_obj", 
	["_radius", 100], 
	["_deadzone", 30], 
	["_strenght", 0.5],
	["_active", true], 
	["_override", false]
]; 

if !(IS_LOCAL(_obj)) exitWith {};

_strenght = (_strenght max 0) min 1;
_deadzone = _radius min _deadzone;

PR _hash = IF_ELSE(IS_STR(_obj), (call REB_fnc_initHash), (0));

IF_(!IS_HASH(_hash), _hash = OBJ_CURR_HASH(_obj));

if (IS_STR(_obj)) then {
	missionNamespace setVariable ["REB_hasRebItems", true, true];
	if (REB_var_rebItemsSystemInited) then {
		_obj remoteExec ["REB_fnc_initRebItems", 2];
	} else {
		_obj remoteExec ["REB_fnc_initRebItemSystem", 0];
	};
} else {
	[_obj, _hash] call REB_fnc_setRebToObj;
};

