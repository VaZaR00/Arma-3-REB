/*
	Class: OO_REB_DB

	Description:
		class which contains and handles global variables for REB system
*/

#include "defines.h"

// #define SAVE_REB_ALL_REBS 0 spawn {sleep (random 0.2); MSVAR ["REB_all_rebs", REB_all_rebs, true];};
// #define SAVE_REB_ALL_CLASSES 0 spawn {sleep (random 0.2); MSVAR ["REB_all_classes", REB_all_classes, -2];};
#define SAVE_REB_ALL_REBS [{publicVariable "REB_all_rebs"}, [], 3] call cba_fnc_execAfterNFrames;;
#define SAVE_REB_ALL_CLASSES [{publicVariable "REB_all_classes"}, [], 3] call cba_fnc_execAfterNFrames;;


CLASS("OO_REB_DB") // IOO_REB_DB

	PUBLIC FUNCTION("","constructor") {
		REB_all_rebs = createHashMap;
		REB_all_classes = createHashMap;
		REB_all_classes_SERVER = createHashMap;
		SAVE_REB_ALL_CLASSES
		SAVE_REB_ALL_REBS
	};

	PUBLIC FUNCTION("","deconstructor") {
		MEMBER("clear_vars", nil);
	};

	PUBLIC FUNCTION("ANY","clear_vars") {
		MSVAR ["REB_all_rebs", nil, true];
		MSVAR ["REB_all_classes", nil, true];
	};

	/* 
		Handle REB_all_classes Methods
	*/

	PUBLIC FUNCTION("string","Add_reb_class") {
		REB_all_classes_SERVER set [_this, call compile _this];
		REB_all_classes set [_this, nil];

		SAVE_REB_ALL_CLASSES
	};

	PUBLIC FUNCTION("string","Remove_reb_class") {
		REB_all_classes_SERVER deleteAt _this;
		REB_all_classes deleteAt _this;

		SAVE_REB_ALL_CLASSES
	};

	/* 
		Handle REB_all_rebs Methods
	*/

	PUBLIC FUNCTION("ANY","Add_reb") {
		if (IS_CODE(_this)) then {
			_this = INSTANCE_VAR(_this, "Object");
		};
		if !(IS_OBJ(_this)) EX;

		REB_all_rebs set [OBJ_HASHVAL(_this), _this];

		SAVE_REB_ALL_REBS
	};

	PUBLIC FUNCTION("ANY","Remove_reb") {
		// PR _name = MEMBER("Make_reb_classname", _this);
		PR _name = METHOD(IOO_OBJECT_REB_DB, "Get_object_hash", _this);

		["Remove_reb", _name, _name in REB_all_rebs, _this] MP_RLOG

		REB_all_rebs deleteAt _name;

		SAVE_REB_ALL_REBS
	};

	// PUBLIC FUNCTION("","Sort_rebs") {
	// 	REB_all_rebs = [REB_all_rebs, [], {INSTANCE_VAR((OBJ_REBS_LIST(_x) select 0), "Range")}, "DESCEND"] call BIS_fnc_sortBy;

	// 	SAVE_REB_ALL_REBS
	// };

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

		REB_all_classes_SERVER getDef [_name, {}];
	};

	PUBLIC FUNCTION("ANY","Get_reb_classname") {
		PR _name = MEMBER("Make_reb_classname", _this);

		if (_name in REB_all_classes_SERVER) then {_name};
	};

ENDCLASS;