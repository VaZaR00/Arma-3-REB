/*
	Class: OO_REB_DB

	Description:
		class which contains and handles global variables for REB system
*/

#include "defines.h"

#define SAVE_REB_ALL_REBS MSVAR ["REB_all_rebs", REB_all_rebs, true];
#define SAVE_REB_ALL_CLASSES MSVAR ["REB_all_classes", REB_all_classes, true];

CLASS("OO_REB_DB") // IOO_REB_DB

	PUBLIC FUNCTION("","constructor") {
		// client
			
		REB_all_rebs = createHashMap;
		REB_all_classes = createHashMap;
	};

	PUBLIC FUNCTION("","deconstructor") {
		MEMBER("clear_vars", nil);
	};

	PUBLIC FUNCTION("","clear_vars") {
		// client

		REB_all_rebs = nil;
		REB_all_classes = nil;
	};

	PUBLIC FUNCTION("string","Add_reb_class") {
		REB_all_classes set [_this, MGVAR _this];

		SAVE_REB_ALL_CLASSES
	};

	PUBLIC FUNCTION("","Add_reb") {
		if (IS_CODE(_this)) then {
			_this = OBJECT_VAR(_this, Object);
		};
		if !(IS_OBJ(_this)) EX;

		REB_all_rebs set [hashValue _this, _this];

		SAVE_REB_ALL_REBS
	};

	PUBLIC FUNCTION("string","Remove_reb_class") {
		REB_all_classes deleteAt _this;

		SAVE_REB_ALL_CLASSES
	};

	PUBLIC FUNCTION("","Remove_reb") {
		PR _name = MEMBER("Make_reb_classname", _this);

		REB_all_rebs deleteAt _name;

		SAVE_REB_ALL_REBS
	};

	PUBLIC FUNCTION("","Make_reb_classname") {
		if (IS_STR(_this) && {REB_CLS_PREF in _this}) EW {_this};

		REB_CLS_PREF +
		(if (IS_STR(_this)) then {
			_this
		} else {
			hashValue _this;
		});
	};

	PUBLIC FUNCTION("","Get_reb_class") {
		PR _name = MEMBER("Make_reb_classname", _this);

		REB_all_classes get _name;
	};

	PUBLIC FUNCTION("","Get_reb_classname") {
		PR _name = MEMBER("Make_reb_classname", _this);

		if (_name in REB_all_classes) then {_name};
	};

ENDCLASS;