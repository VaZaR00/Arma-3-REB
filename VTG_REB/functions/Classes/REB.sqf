/*
	Class: OO_REB

	Description:
		Main REB class representing 
		REB device with its built in 
		parameters.
*/

#include "oop.h"
#include "defines.h"


CLASS("OO_REB")

	PUBLIC VARIABLE("string","Name");
	PUBLIC VARIABLE("object","Init_object");
	PUBLIC VARIABLE("string","Init_object_class");
	PUBLIC VARIABLE("scalar","Max_Range");
	PUBLIC VARIABLE("scalar","Max_Deadzone");
	PUBLIC VARIABLE("scalar","Max_Strenght");
	PUBLIC VARIABLE("scalar","Ratio");
	PUBLIC VARIABLE("scalar","Is_on");
	PUBLIC VARIABLE("scalar","Can_modify_range");
	PUBLIC VARIABLE("scalar","Can_modify_strenght");
	PUBLIC VARIABLE("array","object_reb_list");

	PUBLIC FUNCTION("","constructor") {
		params["_obj", ["_range", 100], ["_deadzone", 30], ["_strenght", 0.6], ["_can_modify_range", true], ["_can_modify_strenght", true], ["_active", true]];

		PR _name = HASH_PREF +
		(if (IS_STR(_obj)) then {
			_obj
		} else {
			hashValue _obj;
		});
		PR _initObj = IF_ELSE(IS_STR(_obj), objNull, _obj);
		PR _initObjClass = IF_ELSE(IS_STR(_obj), _obj, typeOf _obj);

		_strenght = (_strenght max 0) min 1;
		_deadzone = _radius min _deadzone;

		MEMBER("Name", _name);
		MEMBER("Init_object", _initObj);
		MEMBER("Init_object_class", _initObjClass);
		MEMBER("Max_Range", _range);
		MEMBER("Max_Deadzone", _deadzone);
		MEMBER("Max_Strenght", _strenght);
		MEMBER("Ratio", (_radius / _deadzone));
		MEMBER("Is_on", BOOL_TO_INT(_active));
		MEMBER("Can_modify_range", BOOL_TO_INT(_can_modify_range));
		MEMBER("Can_modify_strenght", BOOL_TO_INT(_can_modify_strenght));
		MEMBER("object_reb_list", []);
	};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("","Toggle_reb_global") {
		MEMBER("Is_on", _this);
	};

	PUBLIC FUNCTION("CODE","Add_reb_object") {
		MEMBER("object_reb_list", nil) pushBackUnique _this;
	};

	PUBLIC FUNCTION("CODE","Remove_reb_object") {
		MEMBER("object_reb_list", nil) - [_this];
	};

ENDCLASS;