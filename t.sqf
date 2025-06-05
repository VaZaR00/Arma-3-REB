{
params["_container", ["_item", ""]];

if (_container isEqualTo objNull) exitWith {};

private _allContainerItems = (((everyContainer _container) apply {_x#0}) + ((getItemCargo _container)#0)) apply {"REB_HASH_" + _x};
private _rebsInContainer = (if ((_item isEqualTo "")) then {(keys REB_all_hashes)} else {[_item]}) select {_x in _allContainerItems};

if (count _rebsInContainer > 0) then {












private _rebsSorted = ([
_rebsInContainer, 
[], 
{([([_x] call REB_fnc_getObjHash),  "REB_var_rebRange",  0] call REB_fnc_getProperty)}, 
"DESCEND", 
{([([_x] call REB_fnc_getObjHash),  "REB_var_hasActiveReb",  false] call REB_fnc_getProperty)}
] call BIS_fnc_sortBy);

hint str  [([([_rebsInContainer select 0] call REB_fnc_getObjHash),  "REB_var_rebRange",  0] call REB_fnc_getProperty), (_rebsInContainer#0), ([_rebsInContainer#0] call REB_fnc_getObjHash)];

if (count _rebsSorted == 0) exitWith {false};

private _rebItem = _rebsSorted#0;

if !(_rebItem in _allContainerItems) exitWIth {false};

hint str [_rebItem, _allContainerItems, _container];








[_container, _rebItem] call REB_fnc_setRebToObj;
_container setVariable ["REB_var_currentRebItem", _rebItem, true];
true
} else {
if (_container in REB_all_rebs) then {

[_container, objNull] call REB_fnc_setRebToObj;
};
_container setVariable ["REB_var_currentRebItem", nil, true];
false
};
}