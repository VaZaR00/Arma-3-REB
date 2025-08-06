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

_this spawn {
	// We init only one REB at time to avoid execution intersections
	WAIT_THIS_SCRIPT

	// Check if RE system is already initialized
	if !(missionNamespace getVariable ["REB_var_INITED", false]) then {
		[] call REB_fnc_rebInit;
	};

	// wait for REB system to be initialized
	waitUntil { (missionNamespace getVariable ["REB_var_INITED", false]) };

	// create REB instance on server backend
	EXEC_ON_SERVER_START

		PR _rebObject = ["new", _this] call OO_REB;

		MSVAR [INSTANCE_VAR(_rebObject, "Name"), _rebObject, true];

	EXEC_ON_SERVER_END

};