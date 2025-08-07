#include "..\defines.h"

params["_object", ["_varname", ""]];

private _actions = _object getVariable [_varName, []];

if (!isNil "_actions" && {!(_actions isEqualTo [])}) then {
    {
        [_object, 0, _x] call ace_interact_menu_fnc_removeActionFromObject;
    } forEach _actions;
    
    _object setVariable [_varname, nil];
};