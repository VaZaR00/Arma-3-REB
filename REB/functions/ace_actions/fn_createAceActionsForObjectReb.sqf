/*
    [object_reb_instance] call REB_fnc_createAceActionsForObjectReb;
    - object_reb_instance: инстанс OO_OBJECT_REB
*/

#include "..\defines.h"

params ["_object", "_rebClassname", "_objectRebHash", "_canModifyStren", "_canModifyRange", "_objectRebName", ["_vehOnlyForCrew", true], ["_linkObjects", []]];

[_object, _rebClassname, _objectRebHash, _canModifyStren, _canModifyRange, _objectRebName, _vehOnlyForCrew] call REB_fnc_createActions;

{
    if (isNil "_x") then {continue};
    if !(_x isEqualType objNull) then {continue};
    if (_x isEqualTo objNull) then {continue};
    [_x, _rebClassname, _objectRebHash, _canModifyStren, _canModifyRange, _objectRebName, _vehOnlyForCrew, _object] call REB_fnc_createActions;
} forEach _linkObjects;