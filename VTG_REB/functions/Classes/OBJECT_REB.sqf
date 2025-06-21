/*
	Class: OO_OBJECT_REB

	Description:
		Helper REB class which handles 
		defined objects REB.
*/

#include "oop.h"
#include "defines.h"

CLASS("OO_OBJECT_REB")

	PUBLIC VARIABLE("object","Object");
	PUBLIC VARIABLE("code","Reb_class");
	PUBLIC VARIABLE("scalar","Range");
	PUBLIC VARIABLE("scalar","Deadzone");
	PUBLIC VARIABLE("scalar","Strenght");
	PUBLIC VARIABLE("scalar","Is_active");
	PRIVATE VARIABLE("scalar","ratio");

	PUBLIC FUNCTION("","constructor") {
		params["_obj", "_rebClass", ["_range", 100], ["_deadzone", 30], ["_strenght", 0.6], ["_active", true], ["_ratio", 100/30]];

		MEMBER("Object", _obj);
		MEMBER("Reb_class", _rebClass);
		MEMBER("Range", _range);
		MEMBER("Deadzone", _deadzone);
		MEMBER("Strenght", _strenght);
		MEMBER("Is_active", _active);
		MEMBER("ratio", _ratio);
	};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("scalar","Set_Range") {
		if (_this > CLASS_MEMBER("OO_REB", "Max_Range", nil)) EW {
			hint LOC "$STR_REB_RANGE_EXCEED_MAX";
		};
		MEMBER("Range", _this);
	};

	PUBLIC FUNCTION("scalar","Set_Strenght") {
		if (_this > CLASS_MEMBER("OO_REB", "Max_Strenght", nil)) EW {
			hint LOC "$STR_REB_STRENGHT_EXCEED_MAX";
		};
		MEMBER("Strenght", _this);
	};

	PUBLIC FUNCTION("","Set_Active") {
		MEMBER("Is_active", BOOL(_this));
	};

ENDCLASS;