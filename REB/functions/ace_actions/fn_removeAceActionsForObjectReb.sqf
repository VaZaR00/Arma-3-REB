/*
    [object_reb_instance] call REB_fnc_removeAceActionsForObjectReb;
*/

#include "..\defines.h"

FILE_ONLY_SPAWN

params ["_objectReb"];

_this = _objectReb;
GET_SERVER_VAL INSTANCE_VAR(_this, "Object"); 
GSRES(private _object);
GET_SERVER_VAL INSTANCE_VAR(_this, "InstanceHash"); 
GSRES(private _objectRebHash);

private _varName = "REB_AceActions_" + _objectRebHash;

[_object, _varName] call REB_fnc_objectRemoveAceActions;