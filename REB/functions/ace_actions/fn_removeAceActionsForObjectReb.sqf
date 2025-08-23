/*
    [object_reb_instance] call REB_fnc_removeAceActionsForObjectReb;
*/

#include "..\defines.h"

FILE_ONLY_SPAWN

params ["_objectReb"];

private _object = INSTANCE_VAR(_objectReb, "Object"); 
private _objectRebHash = INSTANCE_VAR(_objectReb, "InstanceHash"); 

private _varName = "REB_AceActions_" + _objectRebHash;

[_object, _varName] call REB_fnc_objectRemoveAceActions;