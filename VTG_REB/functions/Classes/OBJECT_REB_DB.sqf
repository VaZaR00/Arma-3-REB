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
		CHECK_THIS

		params["_obj", ["_rebRef", _this#0]];

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
		_objRebs set [_hsh, nil];
		REB_ALL_OBJECT_REBS set [_hsh, _objectReb];

		MEMBER("Set_object_helper_vars", [_obj C _objectReb]);

		SAVE_OBJ_REBS_LIST_SERVER
		SAVE_OBJ_REBS_LIST
	};

	PUBLIC FUNCTION("array","Remove_from_object") {
		// args types: [string / code / object]

		params["_obj", ["_rebRef", _this#0]];

		PR _objectReb = MEMBER('Get_object_reb', [_obj C _rebRef C _rebRef]);

		IF_NIL_EX(_objectReb);

		OBJ_REBS_LIST_VAR_SERVER
		OBJ_REBS_LIST_VAR

		PR _hsh = HASHVAL_(_objectReb);

		_objRebs_SERVER deleteAt _hsh;
		_objRebs deleteAt _hsh;

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

		PR _objRebs = OBJ_REBS_LIST_SERVER(_obj);

		if (!IS_ARR(_objRebs) || ARR_EMPTY(_objRebs)) EX;
		
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
					if (_ref in INSTANCE_VAR(_x, "Reb_classname")) EW {
						_res = _x;
					};
				};
				IF_(_res != 0, _res);
			};
			case (IS_OBJ(_itemRef)): {
				_objRebs apply {
					if (INSTANCE_VAR(_x, "item_ref") EQTO _itemRef) EW {
						_res = _x;
					};
				};
				IF_(_res != 0, _res);
			};
			case (IS_OBJ(_ref)): {
				PR _cls = METHOD(IOO_REB_DB, 'Get_reb_class', _ref);

				if (isNil "_cls") EX;

				_objRebs apply {
					if (INSTANCE_VAR(_x, "Reb_class") EQTO _cls) EW {
						_res = _x;
					};
				};
				IF_(_res != 0, _res);
			};
			default {};
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

	PUBLIC FUNCTION("array","Get_items_object_rebs") {
		// Get all OBJECT_REB instances that has itemRef so that they created for item,
		// or get all container objects

		params["_obj", ["_getHash", false], ["_keyIsConatinerHash", false], ["_keyIsClass", false]];

		OBJ_REBS_LIST_VAR_SERVER_P(_this);

		PR _toArr = _objRebs_SERVER toArray false;
		MAP(_toArr) { [IF_ELSE(_keyIsClass, (INSTANCE_VAR((_x select 1) C "Reb_classname")), (_x select 0)), [_x#1, INSTANCE_VAR((_x select 1), "item_ref")]] };
		
		PR _res = _toArr select {
			// hash format: [cls or hashVal, [instance, itemRef]]
			!IS_OBJNULL(((_x select 1) select 1))
		};
		
		if (_keyIsConatinerHash) then {
			// hash format: [hashVal of itemRef, instance]
			MAP(_res) { [hashValue (_x#1#1), (_x#1#0)] };
		};

		if (_getHash) then {
			createHashMapFromArray _res;
		} else {
			_res apply {_x#1#1};
		};
	};

	PUBLIC FUNCTION("array","Handle_container") {
		/*
			1. Get all items of container.
				- Select only REB Class items. = _rebsInContainer
			2. Get all item OBJECT_REB instances of container/object = _objRebsConatiners
			3. Check if all _rebsInContainer are in _objRebsConatiners if not add
			4. if OBJECT_REB is not in _rebsInContainer then remove
		*/

		params["_container"];

		PR _isUnit = _container in allUnits;

		PR _allContainerItems = IF_ELSE(_isUnit, [backpackContainer _container], (everyBackpack _container)) apply {[_x, RC_PREF((typeOf _x)), (typeOf _x), (hashValue _x)]};
		PR _rebsInContainer = _allContainerItems select {((_x#1) in REB_all_classes) || ((_x#2) in REB_var_rebItemsClasses)};
		PR _rebsInContainerHashes = _rebsInContainer apply {_x#3};

		// IF_EX(ARR_EMPTY(_rebsInContainer));
		
		PR _objRebsConatiners = MEMBER("Get_items_object_rebs", [_container C true C true]);

		{
			_x params ["_holder", "_reb_class", "_holderClass"];

			if !((hashValue _holder) in _objRebsConatiners) then {
				[_container, _reb_class, _holder] call REB_fnc_addRebOnObj;
			};
		} forEach _rebsInContainer;
		{
			if !(_x in _rebsInContainerHashes) then {
				[_container, _y, INSTANCE_VAR(_y, "item_ref")] call REB_fnc_removeRebOnObj;
			};
		} forEach _objRebsConatiners;
	};

ENDCLASS;