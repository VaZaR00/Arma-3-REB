//reb - [object, radius, deadzone, strenght]

// [_this, 100, 30, 0.5] spawn REB_fnc_reb;

#include "defines.h"

sleep 0.1;
waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

EXEC_ON_SERVER

	PR _rebObject = ["new", _this] call OO_REB;

	MSVAR [INSTANCE_VAR(_rebObject, "Name"), _rebObject, true];

EXEC_ON_SERVER_END