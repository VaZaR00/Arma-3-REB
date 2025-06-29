/*
	Class: OO_REB

	Description:
		Main REB class representing 
		REB device with its built in 
		parameters.
*/

#include "defines.h"


CLASS("OO_REB") // IOO_REB

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

		PR _name = METHOD(IOO_REB_DB, 'Make_reb_classname', nil);
		PR _initObj = IF_ELSE(IS_STR(_obj), objNull, _obj);
		PR _initObjClass = IF_ELSE(IS_STR(_obj), _obj, typeOf _obj);
		PR _ratio = (_radius / _deadzone);

		_strenght = (_strenght max 0) min 1;
		_deadzone = _radius min _deadzone;

		MEMBER("Name", _name);
		MEMBER("Init_object", _initObj);
		MEMBER("Init_object_class", _initObjClass);
		MEMBER("Max_Range", _range);
		MEMBER("Max_Deadzone", _deadzone);
		MEMBER("Max_Strenght", _strenght);
		MEMBER("Ratio", _ratio);
		MEMBER("Is_on", BOOL_TO_INT(_active));
		MEMBER("Can_modify_range", BOOL_TO_INT(_can_modify_range));
		MEMBER("Can_modify_strenght", BOOL_TO_INT(_can_modify_strenght));
		MEMBER("object_reb_list", []);

		METHOD(IOO_REB_DB, 'Add_reb_class', _name);

		if (IS_OBJ(_obj)) then {
			MEMBER("New_reb_object", _obj);
		};
	};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("","Toggle_reb_global") {
		MEMBER("Is_on", _this);
	};

	/*
		Function: New_reb_object

		Description:
			Sets reb to object
		
		Arguments:
			*CODE* OOP Class
	*/
	PUBLIC FUNCTION("object","New_object_reb") {
		if (IS_OBJNULL(_this)) EX;

		PR _rebObject = ["new", [
			_this,
			SELF_VAR('Name'),
			SELF_VAR('Max_Range'),
			SELF_VAR('Max_Deadzone'),
			SELF_VAR('Max_Strenght'),
			SELF_VAR('Is_on'),
			SELF_VAR('Ratio')
		]] call OO_OBJECT_REB;
	};

	PUBLIC FUNCTION("CODE","Delete_object_reb") {
		DELETE(_this);
	};

	PUBLIC FUNCTION("CODE","Add_object_reb_to_list") {
		SELF_VAR('object_reb_list') pushBackUnique _this;
	};

	PUBLIC FUNCTION("CODE","Remove_object_reb_from_list") {
		SELF_VAR('object_reb_list') - [_this];
	};

ENDCLASS;