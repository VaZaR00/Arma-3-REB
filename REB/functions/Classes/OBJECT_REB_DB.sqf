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

		PR _hsh = INSTANCE_VAR(_objectReb, "InstanceHash");

		_objRebs_SERVER set [_hsh, _objectReb];
		_objRebs set [_hsh, INSTANCE_VAR(_objectReb, "item_ref")];
		REB_ALL_OBJECT_REBS set [_hsh, _objectReb];

		METHOD(_objectReb, "Set_object_helper_vars", false);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST

		METHOD(IOO_REB_DB, 'Add_reb', _obj);

		true
	};

	PUBLIC FUNCTION("ANY","Remove") {
		params[["_obj", GET_OR_OBJ((_this select 0))], ["_rebRef", _this#0, [objNull, {}, "", 0]]];

		PR _objectReb = if !(IS_OBJ(_obj)) then {
			PR _t = _obj;
			_obj = INSTANCE_VAR(_obj, "Object");
			_t
		} else {
			MEMBER('Get_object_reb', [_obj C _rebRef C _rebRef]);
		};

		if !(IS_OBJ(_obj)) EX;

		IF_NIL_EX(_objectReb);

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		PR _hsh = INSTANCE_VAR(_objectReb, "InstanceHash");

		_objRebs_SERVER deleteAt _hsh;
		_objRebs deleteAt _hsh;
		REB_ALL_OBJECT_REBS deleteAt _hsh;

		METHOD(_objectReb, "Set_object_helper_vars", true);

		DELETE(_objectReb);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST

		METHOD(IOO_REB_DB, 'Remove_reb', _obj);

		true
	};

	PUBLIC FUNCTION("object","Clear_object_var") {
		PR _obj = _this;

		OBJ_REBS_LIST_VAR_SERVER

		_objRebs_SERVER apply {
			REB_ALL_OBJECT_REBS deleteAt _x;
			MEMBER('Remove', [_obj C _y]);
		};

		_obj SV [ROVAR_S, nil];
		_obj SV [ROVAR, nil, true];
	};

	PUBLIC FUNCTION("array","Get_object_reb") {
		// get OO_OBJECT_REB instance from REB_objectRebs object variable by any reference 

		params["_obj", "_ref", ["_itemRef", 0]];

		if (!(IS_OBJ(_obj)) && {!IS_OOP(_obj)}) EX;

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
			case (_ref isEqualType 1): {
				(values _objRebs) select _ref;
			};
			case (IS_OOP(_ref)): {
				if !(IS_INSTANCE_OF(_ref, "OO_OBJECT_REB")) EX;

				_hsh = INSTANCE_VAR(_ref, "InstanceHash");

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

		OBJ_HASHVAL(_obj);
	};

ENDCLASS;