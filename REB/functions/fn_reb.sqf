/*
	Function: REB_fnc_reb

	Description:
		Initializes a REB instance for the given object with specified parameters.
		Ensures only one REB is initialized at a time and that the REB system is ready before proceeding.
		Handles server-side creation and registration of the REB instance.

	Parameters:
		0: Object [OBJECT] - The object to attach the REB to.
		1: Radius [NUMBER] - Radius of the REB effect.
		2: Deadzone [NUMBER] - Deadzone radius where the effect is inactive.
		3: Strength [NUMBER] - Strength of the REB effect.
		4: Is attachable [BOOL] - Whether the REB is attachable.
		5: Can modify range [BOOL] - Whether the range can be modified.
		6: Can modify strength [BOOL] - Whether the strength can be modified.
		7: Is active [BOOL] - Whether the REB is active.

	Returns:
		None

	Example:
		[_object, 100, 30, 0.5, true] call REB_fnc_reb;
*/

#include "defines.h"

FILE_ONLY_SPAWN

// init only one REB at time to avoid execution intersections
WAIT_THIS_SCRIPT

PR _obj = _this select 0;

sleep 0.1; // wait for mission fully initialized

// Ensure the function is only executed where the object is local on mission init
if !(local _obj) exitWith {
	// if mission time is less than 1 second, we assume its init and all clients are executing it including server
	if (time > 1) then {
		_this remoteExec ["REB_fnc_reb", OBJ_OWNER(_obj)];
	}; 
};

// Check if REB system is already initialized
if !(missionNamespace getVariable ["REB_var_INITED", false]) then {
	// [] remoteExec ["REB_fnc_rebInit", 0, true];
	MSVAR ["REB_var_START_INIT", true, true];
};

// wait for REB system to be initialized
waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

// create REB instance on server backend
EXEC_ON_SERVER_START
	ENSURE_SPAWN_ONCE_START

		// check if the REB class already exists
		PR _name = METHOD(IOO_REB_DB, 'Make_reb_classname', (_this select 0));
		PR _previousClass = MGVAR [_name, {}];

		// if the REB class already exists, just apply new parameters on it
		if !(_previousClass isEqualTo {}) exitWith {
			METHOD(_previousClass, "constructor", _this)
		};

		PR _rebObject = ["new", _this] call OO_REB;

	ENSURE_SPAWN_ONCE_END
EXEC_ON_SERVER_END
