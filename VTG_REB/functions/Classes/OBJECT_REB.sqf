/*
	Class: OO_OBJECT_REB

	Description:
		Helper temporary REB class which handles 
		current object REB.
*/

#include "defines.h"

CLASS("OO_OBJECT_REB") // IOO_OBJECT_REB

	PUBLIC VARIABLE("object","Object");
	PUBLIC VARIABLE("string","Reb_classname");
	PUBLIC VARIABLE("code","Reb_class");
	PUBLIC VARIABLE("scalar","Range");
	PUBLIC VARIABLE("scalar","Deadzone");
	PUBLIC VARIABLE("scalar","Strenght");
	PUBLIC VARIABLE("bool","Is_active");
	PUBLIC VARIABLE("scalar","ratio");
	PUBLIC VARIABLE("object","item_ref"); // reference to dummyweapon placeholder for backpack

	PUBLIC FUNCTION("array","constructor") {
		params["_obj", "_rebClassname", ["_range", 100], ["_deadzone", 30], ["_strenght", 0.6], ["_active", true], ["_ratio", 100/30], ["_itemRef", objNull]];

		_rebClass = call compile _rebClassname;

		MEMBER("Object", _obj);
		MEMBER("Reb_classname", _rebClassname);
		MEMBER("Reb_class", _rebClass);
		MEMBER("Range", _range);
		MEMBER("Deadzone", _deadzone);
		MEMBER("Strenght", _strenght);
		MEMBER("Is_active", _active);
		MEMBER("ratio", _ratio);
		MEMBER("item_ref", _itemRef);

		[_obj] call REB_fnc_setEventHandlers;

		_instance
	};

	PUBLIC FUNCTION("ANY","deconstructor") {
		[SELF_VAR("Object")] call REB_fnc_removeEventHandlers;
	};

	PUBLIC FUNCTION("scalar","Set_Range") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Range")) EW {
			hint LOC "$STR_REB_RANGE_EXCEED_MAX";
		};

		PR _newDeadzone = _this / SELF_VAR('ratio');

		MEMBER("Range", _this);
		MEMBER("Deadzone", _newDeadzone);
	};

	PUBLIC FUNCTION("scalar","Set_Strenght") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Strenght")) EW {
			hint LOC "$STR_REB_STRENGHT_EXCEED_MAX";
		};
		MEMBER("Strenght", _this);
	};

	PUBLIC FUNCTION("BOOL","Set_Active") {
		MEMBER("Is_active", _this);
	};

ENDCLASS;