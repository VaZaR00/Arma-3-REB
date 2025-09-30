/*
	Class: OO_OBJECT_REB

	Description:
		Helper temporary REB class which handles 
		current object REB.
*/

#include "defines.h"


CLASS("OO_OBJECT_REB") // IOO_OBJECT_REB

	PUBLIC VARIABLE("object","Object");

	PUBLIC OBJECT_VAR_SETTER("string","Reb_classname", "");
	PUBLIC OBJECT_VAR_SETTER("code","Reb_class", {});
	PUBLIC OBJECT_VAR_SETTER("scalar","Max_Range", -1);
	PUBLIC OBJECT_VAR_SETTER("scalar","Max_Deadzone", -1);
	PUBLIC OBJECT_VAR_SETTER("scalar","Max_Strenght", 0);
	PUBLIC OBJECT_VAR_SETTER("scalar","Range", -1);
	PUBLIC OBJECT_VAR_SETTER("scalar","Deadzone", -1);
	PUBLIC OBJECT_VAR_SETTER("scalar","Strenght", 0);
	PUBLIC OBJECT_VAR_SETTER("bool","Is_active", false);
	PUBLIC OBJECT_VAR_SETTER("bool","Has_reb", false);
	PUBLIC OBJECT_VAR_SETTER("scalar","ratio", 1);
	PUBLIC OBJECT_VAR_SETTER("object","item_ref", objNull); // reference to dummyweapon placeholder for backpack
	PUBLIC OBJECT_VAR_SETTER("bool","SimulateDamage", false);
	PUBLIC OBJECT_VAR_SETTER("scalar","SimulatedHealth", 0);
	PUBLIC OBJECT_VAR_SETTER("bool","Can_modify_range", true);
	PUBLIC OBJECT_VAR_SETTER("bool","Can_modify_strenght", false);

	PUBLIC SERVER_FUNCTION("array","constructor") { // executed only on server
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
			["_health", 100],
			["_can_modify_range", true], 
			["_can_modify_strenght", false]
		];

		PR _rebClass = call compile _rebClassname;
		PR _hash = SELF_VAR("InstanceHash");

		if !(_obj isEqualTo objNull) then {
			_simulateDamage = (getText (configFile >> "CfgVehicles" >> (typeOf _obj) >> "destrType")) isEqualTo "DestructNo";
		};

		MEMBER("SelfObjVarSetterObject", _obj);
		MEMBER("SelfObjVarSetterPrefix", (PREF_VAR + _hash));

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
		MEMBER("Can_modify_range", _can_modify_range);
		MEMBER("Can_modify_strenght", _can_modify_strenght);

		PR _maxRange = INSTANCE_VAR(_rebClass, "Max_Range");
		PR _maxDeadzone = INSTANCE_VAR(_rebClass, "Max_Deadzone");
		PR _maxStrenght = INSTANCE_VAR(_rebClass, "Max_Strenght");

		MEMBER("Max_Range", _maxRange);
		MEMBER("Max_Deadzone", _maxDeadzone);
		MEMBER("Max_Strenght", _maxStrenght);

		if (_simulateDamage) then {
			[_obj, _simulateDamage, _health] remoteExec ["REB_fnc_simulateDamage", 0, true];
		};
		[_obj] remoteExec ["REB_fnc_setEventHandlers", 0, true];
		[_obj, _rebClassname, _hash, _can_modify_strenght, _can_modify_range, _ooInstanceName] remoteExec ["REB_fnc_createAceActionsForObjectReb", 0, true];

		_ooSelf
	};

	PUBLIC FUNCTION("ANY","deconstructor") { // executed on every client
		PR _obj = SELF_VAR("Object");
		[_obj] call REB_fnc_removeEventHandlers;
		[_ooSelf] call REB_fnc_removeAceActionsForObjectReb;
	};

	PUBLIC FUNCTION("scalar","Set_Range") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Range")) EW {
			hint LOC "$STR_REB_RANGE_EXCEED_MAX";
		};

		PR _newDeadzone = _this / SELF_VAR('ratio');

		MEMBER("Range", _this);
		MEMBER("Deadzone", _newDeadzone);
	};

	PUBLIC FUNCTION("scalar","Set_Strenght") {
		if (_this > INSTANCE_VAR(SELF_VAR('Reb_class'), "Max_Strenght")) EW {
			hint LOC "$STR_REB_STRENGHT_EXCEED_MAX";
		};
		MEMBER("Strenght", _this);
	};

	PUBLIC FUNCTION("BOOL","Set_Active") {
		MEMBER("Is_active", _this);

		// SELF_VAR("Object") setVariable [format["REB_var_OBJECT_REB_IS_ACTIVE_%1", SELF_VAR("InstanceHash")], _this, true];
	};

ENDCLASS;