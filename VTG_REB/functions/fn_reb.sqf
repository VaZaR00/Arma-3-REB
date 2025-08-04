//reb - [object, radius, deadzone, strenght, attachable]

// [_this, 100, 30, 0.5, true] call REB_fnc_reb;

#include "defines.h"

_this spawn {

	sleep 0.1;
	waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

	EXEC_ON_SERVER_START

		PR _rebObject = ["new", _this] call OO_REB;

		MSVAR [INSTANCE_VAR(_rebObject, "Name"), _rebObject, true];

	EXEC_ON_SERVER_END

};