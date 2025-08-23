/*
	Class: OO_REB_DB

	Description:
		class which contains and handles global variables for REB system
		ALL instances of OO_REB are stored in REB_all_classes variable as string: 
		name of its missionNamespace variable.
*/

#include "defines.h"



CLASS("OO_REB_DB") // IOO_REB_DB

	/*
		Variables
	*/
	PUBLIC SETTER("hashMap","REB_all_rebs") {
		/* 
			variable which contains all REB instances in the mission 

			key: [string] object hashval
			value: [object] object instance
		*/
		IF_SET
			MSVAR ["REB_all_rebs", _this, true];
		IF_GET
			MGVAR ["REB_all_rebs", createHashMap];
	};
	PUBLIC SETTER("hashMap","REB_all_classes") {
		/* 
			variable which contains all REB classes in the mission

			key: [string] class name (variable name in missionNamespace)
			value: [bool] true (placeholder)
		*/
		IF_SET
			MSVAR ["REB_all_classes", _this, true];
		IF_GET
			MGVAR ["REB_all_classes", createHashMap];
	};

	/*
		Constructor / Deconstructor
	*/
	PUBLIC SERVER_FUNCTION("","constructor") {
		MEMBER('REB_all_rebs', createHashMap);
		MEMBER('REB_all_classes', createHashMap);
	};

	PUBLIC SERVER_FUNCTION("","deconstructor") {
		MEMBER("clear_vars", nil);
	};

	PUBLIC SERVER_FUNCTION("ANY","clear_vars") {
		MSVAR ["REB_all_rebs", nil, true];
		MSVAR ["REB_all_classes", nil, true];
	};

	/* 
		Handle REB_all_classes Methods
	*/

	PUBLIC SERVER_FUNCTION("string","Add_reb_class") {
		REB_all_classes set [_this, true];

		MEMBER('REB_all_classes', REB_all_classes);
	};

	PUBLIC SERVER_FUNCTION("string","Remove_reb_class") {
		REB_all_classes deleteAt _this;

		MEMBER('REB_all_classes', REB_all_classes);
	};

	/* 
		Handle REB_all_rebs Methods
	*/

	PUBLIC SERVER_FUNCTION("ANY","Add_reb") {
		if (IS_CODE(_this)) then {
			_this = INSTANCE_VAR(_this, "Object");
		};
		if !(IS_OBJ(_this)) EX;

		REB_all_rebs set [OBJ_HASHVAL(_this), _this];

		MEMBER('REB_all_rebs', REB_all_rebs);
	};

	PUBLIC SERVER_FUNCTION("ANY","Remove_reb") {
		PR _name = METHOD(IOO_OBJECT_REB_DB, "Get_object_hash", _this);

		REB_all_rebs deleteAt _name;

		MEMBER('REB_all_rebs', REB_all_rebs);
	};

	/* 
		Other Methods
	*/

	PUBLIC FUNCTION("ANY","Make_reb_classname") {
		call REB_fnc_makeRebClassname
	};

	PUBLIC FUNCTION("ANY","Get_reb_class") {
		PR _name = if (!IS_OOP(_this)) then {
			MEMBER("Make_reb_classname", _this);
		} else {
			INSTANCE_VAR(_this, "Reb_classname");
		};

		if (_name in SELF_VAR('REB_all_classes')) then {
			MGVAR [_name, {}];
		} else {{}};
	};

	PUBLIC FUNCTION("ANY","Get_reb_classname") {
		PR _name = MEMBER("Make_reb_classname", _this);

		if (_name in SELF_VAR('REB_all_classes')) then {_name};
	};

ENDCLASS;