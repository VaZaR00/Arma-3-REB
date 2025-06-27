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

params["_obj", ["_operation", (_this#0)]];

if !(IS_LOCAL(_obj)) EX;

if !(IS_REB(_obj)) EX;

if !(IS_BOOL(_operation) && {_operation}) EW {
	["Clear", [_obj]] call IOO_OBJECT_REB_DB;
};

["Remove", [_obj, _obj]] call IOO_OBJECT_REB_DB;