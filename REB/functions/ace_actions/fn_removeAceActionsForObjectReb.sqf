/*
    [object_reb_instance] call REB_fnc_removeAceActionsForObjectReb;
*/

#include "..\defines.h"

FILE_ONLY_SPAWN

params ["_objectReb"];

GET_SERVER_VAL(private _object, INSTANCE_VAR(_objectReb C "Object"));
GET_SERVER_VAL(private _actions, INSTANCE_VAR(_objectReb C "Ace_actions"));

if (!isNil "_actions" && {!(_actions isEqualTo [])}) then {
    {
        [_object, 0, _x] call ace_interact_menu_fnc_removeActionFromObject;
    } forEach _actions;
    
    if (isServer) then {
        METHOD(_objectReb, "Ace_actions", []);
    };
};