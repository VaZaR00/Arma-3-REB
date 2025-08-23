/*
	Class: OO_OBJECT_REB_DB

	Description:
		class which handles variable "REB_objectRebs" of any object.
		ALL instances of OO_OBJECT_REB are stored in ROVAR (REB_var_objectRebs) variable as: 
			key: [string] instance hash
			value: [string] instance name - its missionNamespace variable.
*/

#include "defines.h"


CLASS("OO_OBJECT_REB_DB") // IOO_OBJECT_REB_DB

	PUBLIC SETTER("hashMap","REB_ALL_OBJECT_REBS") {
		/*
			global hashMap of all OO_OBJECT_REB instances

			key: [string] instance hash
			value: [string] instance name 
		*/
		IF_SET
			MSVAR ["REB_ALL_OBJECT_REBS", _this, true];
		IF_GET
			MGVAR ["REB_ALL_OBJECT_REBS", createHashMap];
	};

	PUBLIC SERVER_FUNCTION("","constructor") {
		MEMBER('REB_ALL_OBJECT_REBS', createHashMap);
	};

	PUBLIC SERVER_FUNCTION("","deconstructor") {
		MSVAR ["REB_ALL_OBJECT_REBS", nil, true];
	};

	PUBLIC SERVER_FUNCTION("array","Add") {
		// args types: [string / code / object]

		params["_obj", "_objectReb"];

		if (IS_OOP(_obj)) then {
			_objectReb = _obj;
			_obj = INSTANCE_VAR(_objectReb, "Object");
		};
		
		// VALIDATIONS
		IF_EX(!IS_OBJ(_obj));
		IF_EX(!IS_OOP(_objectReb));

		// GET VALUES
		PR _hsh = INSTANCE_VAR(_objectReb, "InstanceHash");
		PR _name = INSTANCE_VAR(_objectReb, "InstanceName");
		PR _objRebs = OBJ_VAR [ROVAR, createHashMap];

		// SET
		_objRebs set [_hsh, _name];
		REB_ALL_OBJECT_REBS set [_hsh, _name];

		// SAVE
		_obj SV [ROVAR, _objRebs, true];
		MEMBER('REB_ALL_OBJECT_REBS', REB_ALL_OBJECT_REBS);

		// ADD TO ALL REBs
		METHOD(IOO_REB_DB, 'Add_reb', _obj);

		true
	};

	PUBLIC SERVER_FUNCTION("ANY","Remove") {
		params[["_obj", GET_OR_OBJ((_this select 0))], ["_rebRef", _this#0, [objNull, {}, "", 0]]];

		PR _objectReb = if !(IS_OBJ(_obj)) then {
			PR _t = _obj;
			_obj = INSTANCE_VAR(_obj, "Object");
			_t
		} else {
			MEMBER('Get_object_reb', [_obj C _rebRef C _rebRef]);
		};

		// VALIDATIONS
		if !(IS_OBJ(_obj)) EX;
		IF_NIL_EX(_objectReb);

		// GET VALUES
		PR _hsh = INSTANCE_VAR(_objectReb, "InstanceHash");
		PR _name = INSTANCE_VAR(_objectReb, "InstanceName");
		PR _objRebs = OBJ_VAR [ROVAR, createHashMap];

		// REMOVE
		_objRebs deleteAt _hsh;
		REB_ALL_OBJECT_REBS deleteAt _hsh;
		DELETE(_objectReb);

		// SAVE
		_obj SV [ROVAR, _objRebs, true];
		MEMBER('REB_ALL_OBJECT_REBS', REB_ALL_OBJECT_REBS);

		// REMOVE FROM ALL REBs
		METHOD(IOO_REB_DB, 'Remove_reb', _obj);

		true
	};

	PUBLIC SERVER_FUNCTION("object","Clear_object_var") {
		PR _obj = _this;

		PR _objRebs = OBJ_VAR [ROVAR, createHashMap];

		_objRebs apply {
			REB_ALL_OBJECT_REBS deleteAt _x;
			MEMBER('Remove', [_obj C _y]);
		};

		_obj SV [ROVAR, createHashMap, true];
		MEMBER('REB_ALL_OBJECT_REBS', REB_ALL_OBJECT_REBS);
	};

	PUBLIC FUNCTION("array","Get_object_reb") {
		// get OO_OBJECT_REB instance from REB_objectRebs object variable by any reference 

		params["_obj", "_ref", ["_itemRef", 0]];

		if (!(IS_OBJ(_obj)) && {!IS_OOP(_obj)}) EX;

		if !(IS_OBJ(_obj)) then {
			_obj = INSTANCE_VAR(_obj, "Object");
		};

		PR _objRebs = OBJ_VAR [ROVAR, createHashMap];

		if (!IS_HASH(_objRebs) || {ARR_EMPTY(_objRebs)}) EX;
		
		if (_itemRef EQTO _ref) then {
			_itemRef = 0;
		};

		PR _hsh = HASHVAL_(_ref);
		PR _res = 0;

		PR _res = switch (true) do {
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
					if (_ref in INSTANCE_VAR(OBJ_REB(_y), "Reb_classname")) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			case (IS_OBJ(_itemRef)): {
				_objRebs apply {
					if (INSTANCE_VAR(OBJ_REB(_y), "item_ref") EQTO _itemRef) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			case (IS_OBJ(_ref)): {
				PR _cls = METHOD(IOO_REB_DB, 'Get_reb_class', _ref);

				if (isNil "_cls") EX;

				_objRebs apply {
					if (INSTANCE_VAR(OBJ_REB(_y), "Reb_class") EQTO _cls) EW {
						_res = _y;
					};
				};
				IF_(!(_res EQTO 0), _res);
			};
			default {
			};
		};

		if !(isNil "_res") exitWith {OBJ_REB(_res)};
	};

	PUBLIC FUNCTION("ANY","Object_reb_exists") {
		params["_obj", "_rebClassname", ["_itemRef", objNull]];

		_res = count (
			(values REB_ALL_OBJECT_REBS) select {
				(INSTANCE_VAR(OBJ_REB(_x), "Object") EQTO _obj) &&
				(INSTANCE_VAR(OBJ_REB(_x), "Reb_classname") EQTO _rebClassname) &&
				(INSTANCE_VAR(OBJ_REB(_x), "item_ref") EQTO _itemRef)
			}
		) > 0;

		_res
	};

	PUBLIC FUNCTION("ANY","Get_object_hash") {
		PR _obj = if (IS_OBJ(_this)) then {
			_this
		} else {
			INSTANCE_VAR(_this, "Object");
		};

		OBJ_HASHVAL(_obj);
	};

ENDCLASS;