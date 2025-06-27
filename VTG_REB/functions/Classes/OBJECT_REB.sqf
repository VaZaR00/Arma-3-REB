/*
	Class: OO_OBJECT_REB

	Description:
		Helper temporary REB class which handles 
		current object REB.
*/

#include "defines.h"

CLASS("OO_OBJECT_REB") // IOO_OBJECT_REB

	PUBLIC VARIABLE("object","Object");
	PUBLIC VARIABLE("code","Reb_class");
	PUBLIC VARIABLE("scalar","Range");
	PUBLIC VARIABLE("scalar","Deadzone");
	PUBLIC VARIABLE("scalar","Strenght");
	PUBLIC VARIABLE("scalar","Is_active");
	PRIVATE VARIABLE("scalar","ratio");

	PUBLIC FUNCTION("","constructor") {
		GLOBALY

		params["_obj", "_rebClassname", ["_range", 100], ["_deadzone", 30], ["_strenght", 0.6], ["_active", true], ["_ratio", 100/30]];

		_rebClass = call compile _rebClassname;

		MEMBER("Object", _obj);
		MEMBER("Reb_classname", _rebClassname);
		MEMBER("Reb_class", _rebClass);
		MEMBER("Range", _range);
		MEMBER("Deadzone", _deadzone);
		MEMBER("Strenght", _strenght);
		MEMBER("Is_active", _active);
		MEMBER("ratio", _ratio);

		METHOD(IOO_OBJECT_REB_DB, Add, [_obj C _instance]);

		METHOD(IOO_REB_DB, Add_reb, _instance);

		METHOD(_rebClass, Add_object_reb_to_list, _rebObject);
	};

	PUBLIC FUNCTION("","deconstructor") {
		GLOBALY

		METHOD(SELF_VAR(Reb_class), Remove_object_reb_from_list, _this);

		METHOD(IOO_REB_DB, Remove_reb, OBJECT_VAR(_this C "Object"));
	};

	PUBLIC FUNCTION("scalar","Set_Range") {
		GLOBALY

		if (_this > OBJECT_VAR(SELF_VAR(Reb_class), Max_Range)) EW {
			hint LOC "$STR_REB_RANGE_EXCEED_MAX";
		};

		PR _newDeadzone = _this / SELF_VAR(ratio);

		MEMBER("Range", _this);
		MEMBER("Deadzone", _newDeadzone);
	};

	PUBLIC FUNCTION("scalar","Set_Strenght") {
		GLOBALY

		if (_this > OBJECT_VAR(SELF_VAR(Reb_class), Max_Strenght)) EW {
			hint LOC "$STR_REB_STRENGHT_EXCEED_MAX";
		};
		MEMBER("Strenght", _this);
	};

	PUBLIC FUNCTION("","Set_Active") {
		GLOBALY
		
		MEMBER("Is_active", BOOL(_this));
	};

	PUBLIC FUNCTION("","Get_object_reb") {
		// get OO_OBJECT_REB instance from REB_objectRebs object variable by any reference 

		params["_obj", "_ref"];

		PR _objRebs = OBJ_REBS_LIST(_obj);

		if (!IS_ARR(_objRebs) || ARR_EMPTY(_objRebs)) EX;

		switch (true) do {
			case (IS_OOP(_ref)): {
				if !(IS_INSTANCE_OF(_ref, "OO_OBJECT_REB")) EX;

				if !(_ref in _objRebs) EX;

				_ref
			};
			case (IS_STR(_ref)): {
				(_objRebs select {_ref in OBJECT_VAR(_x, Reb_classname)})#0;
			};
			case (IS_OBJ(_ref)): {
				PR _cls = METHOD(IOO_REB_DB, Get_reb_class, _ref);

				if (isNil "_cls") EX;

				(_objRebs select {OBJECT_VAR(_x, Reb_class) EQTO _cls})#0;
			};
			default {};
		};
	};

	PUBLIC FUNCTION("","Is_object_reb") {
		OBJECT_VAR(_this, classname) EQTO _class;
	};

ENDCLASS;