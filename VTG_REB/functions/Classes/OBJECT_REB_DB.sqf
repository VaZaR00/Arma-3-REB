/*
	Class: OO_OBJECT_REB_DB

	Description:
		class which handles variable "REB_objectRebs" of any object
*/

#include "defines.h"


CLASS("OO_OBJECT_REB_DB") // IOO_OBJECT_REB_DB

	PUBLIC FUNCTION("","constructor") {};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("","Add") {
		// args types: [string / code / object]

		params["_obj", "_objectReb"];

		IF_EX(!IS_OOP(_objectReb));

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		_objRebs_SERVER set [(hashValue _objectReb), _objectReb];
		_objRebs set [(hashValue _objectReb), nil];

		MEMBER("Set_helper_vars", [_obj C _or]);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST
	};

	PUBLIC FUNCTION("","Remove") {
		// args types: [string / code / object]

		params["_obj", "_or"];

		PR _objectReb = MEMBER('Get_object_reb', _this);

		IF_NIL_EX(_objectReb);

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		_objRebs_SERVER deleteAt (hashValue _objectReb);
		_objRebs deleteAt (hashValue _objectReb);

		MEMBER("Set_helper_vars", [_obj C _or C true]);

		DELETE(_objectReb);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST
	};

	PUBLIC FUNCTION("","Clear") {
		params["_obj"];

		OBJ_REBS_LIST_VAR_SERVER

		_objRebs_SERVER apply {
			DELETE(_y);
		};

		_obj SV [ROVAR_S, nil];
		_obj SV [ROVAR, nil, true];
	};

	PUBLIC FUNCTION("","Set_helper_vars") {
		params["_obj", "_or", ["_nil", false]];

		[
			INSTANCE_VAR(_or, "Range"),
			INSTANCE_VAR(_or, "Deadzone"),
			INSTANCE_VAR(_or, "Strenght"),
			INSTANCE_VAR(_or, "Is_active"),
			INSTANCE_VAR(_or, "ratio"),
			INSTANCE_VAR(_or, "Reb_classname")
		] params ["_range", "_deadzone", "_strenght", "_isActive", "_ratio", "_rebClassname"];

		PR _hashVal = hashValue _or;

		_obj SV [ROVAR_NAME("_range"), IF_ELSE(_nil, nil, _range), true];
		_obj SV [ROVAR_NAME("_deadzone"), IF_ELSE(_nil, nil, _deadzone), true];
		_obj SV [ROVAR_NAME("_strenght"), IF_ELSE(_nil, nil, _strenght), true];
		_obj SV [ROVAR_NAME("_isActive"), IF_ELSE(_nil, nil, _isActive), true];
		_obj SV [ROVAR_NAME("_ratio"), IF_ELSE(_nil, nil, _ratio), true];
		_obj SV [ROVAR_NAME("_rebClassname"), IF_ELSE(_nil, nil, _rebClassname), true];
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
				(_objRebs select {_ref in INSTANCE_VAR(_x, "Reb_classname")})#0;
			};
			case (IS_OBJ(_ref)): {
				PR _cls = METHOD(IOO_REB_DB, 'Get_reb_class', _ref);

				if (isNil "_cls") EX;

				(_objRebs select {INSTANCE_VAR(_x, "Reb_class") EQTO _cls})#0;
			};
			default {};
		};
	};

	// PUBLIC FUNCTION("ARRAY","Sort") {
	// 	_this = [_this, [], {INSTANCE_VAR(_x, "Range")}, "DESCEND"] call BIS_fnc_sortBy;

	// 	SAVE_ROVAR
	// };

ENDCLASS;