/*
	Class: OO_OBJECT_REB

	Description:
		Helper temporary REB class which handles 
		current object REB.
*/

#include "defines.h"

CLASS("OO_OBJECT_REB") // IOO_OBJECT_REB

	PUBLIC VARIABLE("string","InstanceHash");
	PUBLIC VARIABLE("object","Object");
	PUBLIC VARIABLE("string","Reb_classname");
	PUBLIC VARIABLE("code","Reb_class");
	PUBLIC VARIABLE("scalar","Range");
	PUBLIC VARIABLE("scalar","Deadzone");
	PUBLIC VARIABLE("scalar","Strenght");
	PUBLIC VARIABLE("bool","Is_active");
	PUBLIC VARIABLE("scalar","ratio");
	PUBLIC VARIABLE("object","item_ref"); // reference to dummyweapon placeholder for backpack
	PUBLIC VARIABLE("bool","SimulateDamage");
	PUBLIC VARIABLE("scalar","SimulatedHealth");

	PUBLIC FUNCTION("array","constructor") {
		params[
			"_obj", 
			"_rebClassname", 
			["_range", 100], 
			["_deadzone", 30], 
			["_strenght", 0.6], 
			["_active", true], 
			["_ratio", 100/30], 
			["_itemRef", objNull], 
			["_simulateDamage", false], 
			["_health", 100]
		];

		PR _rebClass = call compile _rebClassname;
		PR _hash = UNQ_HASHVAL(_instance, _obj);

		MEMBER("InstanceHash", _hash);
		MEMBER("Object", _obj);
		MEMBER("Reb_classname", _rebClassname);
		MEMBER("Reb_class", _rebClass);
		MEMBER("Range", _range);
		MEMBER("Deadzone", _deadzone);
		MEMBER("Strenght", _strenght);
		MEMBER("Is_active", _active);
		MEMBER("ratio", _ratio);
		MEMBER("item_ref", _itemRef);
		MEMBER("SimulateDamage", _simulateDamage);
		MEMBER("SimulatedHealth", _health);

		["OBJECT_REB_constructor", _obj] MP_RLOG

		_obj setVariable [format["REB_var_OBJECT_REB_IS_ACTIVE_%1", _hash], _active, true];

		if (_simulateDamage) then {
			[_obj, _simulateDamage, _health] remoteExec ["REB_fnc_simulateDamage", 0, true];
		};
		[_obj] remoteExec ["REB_fnc_setEventHandlers", 0, true];
		[_instance] remoteExec ["REB_fnc_createAceActionsForObjectReb", 0, true];

		_instance
	};

	PUBLIC FUNCTION("ANY","deconstructor") {
		PR _obj = SELF_VAR("Object");
		// if (IS_REB(_obj)) exitWith {};
		[_obj] remoteExec ["REB_fnc_removeEventHandlers", 0, true];
		[_instance] remoteExec ["REB_fnc_removeAceActionsForObjectReb", 0, true];
		// [_obj, false] call REB_fnc_setAttachable;
	};

	PUBLIC FUNCTION("scalar","Set_Range") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Range")) EW {
			hint LOC "$STR_REB_RANGE_EXCEED_MAX";
		};

		PR _newDeadzone = _this / SELF_VAR('ratio');

		MEMBER("Range", _this);
		MEMBER("Deadzone", _newDeadzone);

		MEMBER("Set_object_helper_vars", false);
	};

	PUBLIC FUNCTION("scalar","Set_Strenght") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Strenght")) EW {
			hint LOC "$STR_REB_STRENGHT_EXCEED_MAX";
		};
		MEMBER("Strenght", _this);

		MEMBER("Set_object_helper_vars", false);
	};

	PUBLIC FUNCTION("BOOL","Set_Active") {
		MEMBER("Is_active", _this);

		SELF_VAR("Object") setVariable [format["REB_var_OBJECT_REB_IS_ACTIVE_%1", SELF_VAR("InstanceHash")], _this, true];

		MEMBER("Set_object_helper_vars", false);
	};
	
	PUBLIC FUNCTION("BOOL","Set_object_helper_vars") {
		PR _nil = _this;

		PR _obj = SELF_VAR("Object");
		PR _hshVal = SELF_VAR("InstanceHash");

		[
			SELF_VAR("Range"),
			SELF_VAR("Deadzone"),
			SELF_VAR("Strenght"),
			SELF_VAR("Is_active"),
			SELF_VAR("ratio"),
			SELF_VAR("Reb_classname")
		] params ["_range", "_deadzone", "_strenght", "_isActive", "_ratio", "_rebClassname"];

		_obj SV [ROVAR_NAME("_range"), IF_ELSE(_nil, nil, _range), true];
		_obj SV [ROVAR_NAME("_deadzone"), IF_ELSE(_nil, nil, _deadzone), true];
		_obj SV [ROVAR_NAME("_strenght"), IF_ELSE(_nil, nil, _strenght), true];
		_obj SV [ROVAR_NAME("_isActive"), IF_ELSE(_nil, nil, _isActive), true];
		_obj SV [ROVAR_NAME("_ratio"), IF_ELSE(_nil, nil, _ratio), true];
		_obj SV [ROVAR_NAME("_rebClassname"), IF_ELSE(_nil, nil, _rebClassname), true];
	};

ENDCLASS;