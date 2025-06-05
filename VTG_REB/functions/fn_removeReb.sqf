// [obj, true] call REB_fnc_removeReb;

#include "defines.h"

params["_obj", ["_full", false]];

if !(IS_LOCAL(_obj)) exitWith {};

if !(IS_REB(_obj)) exitWith {};

_obj remoteExec ["REB_fnc_removeActions", 0];

[_obj, objNull] call REB_fnc_setRebToObj;
[_obj] call REB_fnc_removeHash;