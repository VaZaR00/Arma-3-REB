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
	PUBLIC VARIABLE("bool","Is_on");
	PUBLIC VARIABLE("bool","Is_attachable");
	PUBLIC VARIABLE("bool","Can_modify_range");
	PUBLIC VARIABLE("bool","Can_modify_strenght");
	PUBLIC VARIABLE("array","object_reb_list");
	PUBLIC VARIABLE("bool","Is_item");

	PUBLIC FUNCTION("array","constructor") {
		params["_obj", ["_range", 100], ["_deadzone", 30], ["_strenght", 0.6], ["_isAttachable", false], ["_can_modify_range", true], ["_can_modify_strenght", true], ["_active", true]];

		PR _name = METHOD(IOO_REB_DB, 'Make_reb_classname', _obj);
		PR _initObj = IF_ELSE(IS_STR(_obj), objNull, _obj);
		PR _initObjClass = IF_ELSE(IS_STR(_obj), _obj, typeOf _obj);
		PR _ratio = (_range / _deadzone);

		_strenght = (_strenght max 0) min 1;
		_deadzone = _range min _deadzone;

		MEMBER("Name", _name);
		MEMBER("Init_object", _initObj);
		MEMBER("Init_object_class", _initObjClass);
		MEMBER("Max_Range", _range);
		MEMBER("Max_Deadzone", _deadzone);
		MEMBER("Max_Strenght", _strenght);
		MEMBER("Ratio", _ratio);
		MEMBER("Is_on", _active);
		MEMBER("Is_attachable", _isAttachable);
		MEMBER("Can_modify_range", _can_modify_range);
		MEMBER("Can_modify_strenght", _can_modify_strenght);
		MEMBER("object_reb_list", []);
		MEMBER("Is_item", IS_STR(_obj));

		MSVAR [_name, _instance];

		METHOD(IOO_REB_DB, 'Add_reb_class', _name);

		if (IS_OBJ(_obj)) then {
			MEMBER("New_object_reb", [_obj]);
		};

		if (!IS_OBJNULL(_initObj) && {(_isAttachable || (getMass _initObj <= 31))}) then {
			[_initObj] call REB_fnc_setAttachable;
		};

		if (!(REB_var_rebItemsSystemInited) && {IS_STR(_obj)}) then {
			[] remoteExec ["REB_fnc_initRebItemSystem", 0, true];
		};
	};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("bool","Toggle_reb_global") {
		MEMBER("Is_on", _this);
	};

	/*
		Function: New_object_reb

		Description:
			Creates new object reb and adds to REB class
		
		Arguments:
			[Object, itemRef (container of backpack)]
	*/
	PUBLIC FUNCTION("ARRAY","New_object_reb") {
		params["_obj", ["_itemRef", objNull]];

		if (IS_OBJNULL(_obj)) EX;
		if (!IS_OBJ(_itemRef)) EX;

		PR _params = [
			_obj,
			SELF_VAR('Name'),
			SELF_VAR('Max_Range'),
			SELF_VAR('Max_Deadzone'),
			SELF_VAR('Max_Strenght'),
			SELF_VAR('Is_on'),
			SELF_VAR('Ratio'),
			_itemRef
		];

		if (METHOD(IOO_OBJECT_REB_DB, "Object_reb_exists", [_obj C SELF_VAR('Name') C _itemRef])) EX;

		PR _objectReb = ["new", _params] call OO_OBJECT_REB;

		MEMBER('Add_object_reb_to_list', _objectReb);

		METHOD(IOO_OBJECT_REB_DB, 'Add', [_obj C _objectReb]);

		_objectReb
	};

	PUBLIC FUNCTION("ARRAY","Delete_object_reb") {
		params["_obj", ["_rebRef", objNull]];

		_this = METHOD(IOO_OBJECT_REB_DB, "Get_object_reb", [_obj C _obj C _rebRef]);

		IF_NIL_EX(_this);

		if !(IS_OOP(_this)) EX;

		MEMBER('Remove_object_reb_from_list', _this);

		METHOD(IOO_OBJECT_REB_DB, 'Remove', _this);

		// DELETE(_this);

		true
	};

	PUBLIC FUNCTION("CODE","Add_object_reb_to_list") {
		SELF_VAR('object_reb_list') pushBackUnique _this;
	};

	PUBLIC FUNCTION("CODE","Remove_object_reb_from_list") {
		SELF_VAR('object_reb_list') - [_this];
	};

ENDCLASS;