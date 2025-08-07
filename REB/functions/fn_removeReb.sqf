/*
	Name: REB_fnc_removeReb

	Author: Vazar
		
	Description:
		Remove reb from object (optionaly fully)

	Arguments: 
		- object [object]: 
		- operation [bool/string/code/object]: fully remove or specified with string or oop code representing reb

	Return Value: Nothing

	Example: [obj, true] call REB_fnc_removeReb;

	Additional: Nothing
*/
#include "defines.h"

PR _obj = _this select 0;

// Ensure the function is only executed where the object is local
if !(local _obj) exitWith {
	_this remoteExec ["REB_fnc_removeReb", IF_ELSE(owner _obj == 0, 2, owner _obj)];
};

EXEC_ON_SERVER_START
	ENSURE_SPAWN_ONCE_START
		params["_obj", ["_operation", (_this#0)]];	

		if !(IS_REB(_obj)) EX;

		if (IS_BOOL(_operation) && {_operation}) EW {
			["REB_fnc_removeReb : Clear_object_var", _this] MP_RLOG
			["Clear_object_var", _obj] call IOO_OBJECT_REB_DB;
		};

		["REB_fnc_removeReb : Remove", _this] MP_RLOG
		["Remove", _this] call IOO_OBJECT_REB_DB;
	ENSURE_SPAWN_ONCE_END
EXEC_ON_SERVER_END