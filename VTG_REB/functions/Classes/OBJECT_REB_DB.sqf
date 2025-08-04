/*
	Class: OO_OBJECT_REB_DB

	Description:
		class which handles variable "REB_objectRebs" of any object
*/

#include "defines.h"


CLASS("OO_OBJECT_REB_DB") // IOO_OBJECT_REB_DB

	PUBLIC FUNCTION("","constructor") {
		REB_ALL_OBJECT_REBS = createHashMap;
	};

	PUBLIC FUNCTION("","deconstructor") {
		REB_ALL_OBJECT_REBS = nil;
	};

	PUBLIC FUNCTION("array","Add") {
		params["_obj", "_instance"];
		
		MEMBER('Add_to_object', [_obj C _instance]);

		METHOD(IOO_REB_DB, 'Add_reb', _obj);
	};

	PUBLIC FUNCTION("ANY","Remove") {
		CHECK_THIS;

		params[["_obj", GET_OR_OBJ((_this select 0))], ["_rebRef", _this#0]];

		MEMBER('Remove_from_object', _this);

		METHOD(IOO_REB_DB, 'Remove_reb', _obj);
	};

	PUBLIC FUNCTION("array","Add_to_object") {
		// args types: [string / code / object]

		params["_obj", "_objectReb"];

		if (IS_OOP(_obj)) then {
			_objectReb = _obj;
			_obj = INSTANCE_VAR(_objectReb, "Object");
		};
		
		IF_EX(!IS_OBJ(_obj));
		IF_EX(!IS_OOP(_objectReb));

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		PR _hsh = HASHVAL_(_objectReb);

		_objRebs_SERVER set [_hsh, _objectReb];
		_objRebs set [_hsh, INSTANCE_VAR(_objectReb, "item_ref")];
		REB_ALL_OBJECT_REBS set [_hsh, _objectReb];

		MEMBER("Set_object_helper_vars", [_obj C _objectReb]);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST
	};

	PUBLIC FUNCTION("ANY","Remove_from_object") {
		// args types: [string / code / object]
		CHECK_THIS;

		params[["_obj", GET_OR_OBJ((_this select 0))], ["_rebRef", _this#0]];

		PR _objectReb = if !(IS_OBJ(_obj)) then {
			PR _t = _obj;
			_obj = INSTANCE_VAR(_obj, "Object");
			_t
		} else {
			MEMBER('Get_object_reb', [_obj C _rebRef C _rebRef]);
		};

		IF_NIL_EX(_objectReb);

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		PR _hsh = HASHVAL_(_objectReb);

		_objRebs_SERVER deleteAt _hsh;
		_objRebs deleteAt _hsh;
		REB_ALL_OBJECT_REBS deleteAt _hsh;

		MEMBER("Set_object_helper_vars", [_obj C _objectReb C true]);

		DELETE(_objectReb);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST
	};

	PUBLIC FUNCTION("array","Clear_object_var") {
		params["_obj"];

		OBJ_REBS_LIST_VAR_SERVER

		_objRebs_SERVER apply {
			REB_ALL_OBJECT_REBS deleteAt _x;
			DELETE(_y);
		};

		_obj SV [ROVAR_S, nil];
		_obj SV [ROVAR, nil, true];
	};

	PUBLIC FUNCTION("array","Set_object_helper_vars") {
		params["_obj", "_objreb", ["_nil", false]];

		[
			INSTANCE_VAR(_objreb, "Range"),
			INSTANCE_VAR(_objreb, "Deadzone"),
			INSTANCE_VAR(_objreb, "Strenght"),
			INSTANCE_VAR(_objreb, "Is_active"),
			INSTANCE_VAR(_objreb, "ratio"),
			INSTANCE_VAR(_objreb, "Reb_classname")
		] params ["_range", "_deadzone", "_strenght", "_isActive", "_ratio", "_rebClassname"];

		PR _hshVal = HASHVAL_(_objreb);

		_obj SV [ROVAR_NAME("_range"), IF_ELSE(_nil, nil, _range), true];
		_obj SV [ROVAR_NAME("_deadzone"), IF_ELSE(_nil, nil, _deadzone), true];
		_obj SV [ROVAR_NAME("_strenght"), IF_ELSE(_nil, nil, _strenght), true];
		_obj SV [ROVAR_NAME("_isActive"), IF_ELSE(_nil, nil, _isActive), true];
		_obj SV [ROVAR_NAME("_ratio"), IF_ELSE(_nil, nil, _ratio), true];
		_obj SV [ROVAR_NAME("_rebClassname"), IF_ELSE(_nil, nil, _rebClassname), true];
	};

	PUBLIC FUNCTION("array","Get_object_reb") {
		// get OO_OBJECT_REB instance from REB_objectRebs object variable by any reference 

		params["_obj", "_ref", ["_itemRef", 0]];

		if !(IS_OBJ(_obj)) then {
			_obj = INSTANCE_VAR(_obj, "Object");
		};

		PR _objRebs = OBJ_REBS_LIST_SERVER(_obj);

		if (!IS_HASH(_objRebs) || {ARR_EMPTY(_objRebs)}) EX;
		
		if (_itemRef EQTO _ref) then {
			_itemRef = 0;
		};

		PR _hsh = HASHVAL_(_ref);
		PR _res = 0;

		switch (true) do {
			case (IS_OOP(_ref)): {
				if !(IS_INSTANCE_OF(_ref, "OO_OBJECT_REB")) EX;

				if !(_hsh in _objRebs) EX;

				_ref
			};
			case (IS_STR(_ref)): {
				_objRebs apply {
					if (_ref in INSTANCE_VAR(_y, "Reb_classname")) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			case (IS_OBJ(_itemRef)): {
				_objRebs apply {
					if (INSTANCE_VAR(_y, "item_ref") EQTO _itemRef) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			case (IS_OBJ(_ref)): {
				PR _cls = METHOD(IOO_REB_DB, 'Get_reb_class', _ref);

				if (isNil "_cls") EX;

				_objRebs apply {
					if (INSTANCE_VAR(_y, "Reb_class") EQTO _cls) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			default {
			};
		};
	};

	PUBLIC FUNCTION("ANY","Object_reb_exists") {
		params["_obj", "_rebClassname", ["_itemRef", objNull]];

		_res = count (
			(values REB_ALL_OBJECT_REBS) select {
				(INSTANCE_VAR(_x, "Object") EQTO _obj) &&
				(INSTANCE_VAR(_x, "Reb_classname") EQTO _rebClassname) &&
				(INSTANCE_VAR(_x, "item_ref") EQTO _itemRef)
			}
		) > 0;

		_res
	};

	// PUBLIC FUNCTION("array","Get_items_object_rebs") {
	// 	// Get all OBJECT_REB instances that has itemRef so that they created for item

	// 	params["_obj"];

	// 	OBJ_REBS_LIST_VAR_SERVER_P(_obj);

	// 	PR _toArr = _objRebs_SERVER toArray false;
	// 	PR _withItems = _toArr select {
	// 		_x params [];
	// 	};
	// };

	PUBLIC FUNCTION("ANY","Get_object_hash") {
		PR _obj = if (IS_OBJ(_this)) then {
			_this
		} else {
			INSTANCE_VAR(_this, "Object");
		};

		HASHVAL_(_obj);
	};

ENDCLASS;