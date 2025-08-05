/*
    [object_reb_instance] call REB_fnc_removeAceActionsForObjectReb;
*/

#include "..\defines.h"

params ["_objectReb"];
private _object = METHOD(_objectReb, "Object", nil);
private _actions = METHOD(_objectReb, "Ace_actions", nil);

_actions RLOG

if (!isNil "_actions" && {!(_actions isEqualTo [])}) then {
    {
        [_object, 0, _x] call ace_interact_menu_fnc_removeActionFromObject;
    } forEach _actions;
    
    if (isServer) then {
        METHOD(_objectReb, "Ace_actions", []);
    };
};