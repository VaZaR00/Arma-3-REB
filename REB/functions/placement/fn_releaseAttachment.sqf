#include "..\defines.h"

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _object = _player getVariable ["REB_currentAttachObj", objNull];
private _objectType = _player getVariable ["REB_currentAttachObjType", ""];
private _item = _player getVariable ["REB_currentAttachItem", ""];
private _tempObj = _player getVariable ["REB_attachmentTempObj", objNull];

if (isNull _object) exitWith {};

// private _safePos = [_player modelToWorld [0,1.5,0], 0, 1.5, 1] call BIS_fnc_findSafePos;

// if ((isNil "_safePos") && {_safePos isEqualTo []}) exitWith {
//     hint LOC "$STR_REB_placement_cannotPlace";
// };

// Если был item — возвращаем его игроку
if (_item != "") then {
    _player addItem _item;
};

_object enableCollisionWith _player;
[_object, true] remoteExec ["enableSimulationGlobal", 2];
// _object setVehiclePosition [_safePos, [], 0, "CAN_COLLIDE"];
_object setPosASL (getPosASL _tempObj);
_object setVectorDirAndUp [vectorDir _tempObj, vectorUp _tempObj];
deleteVehicle _tempObj;

// Очистка переменных
call REB_fnc_clearAttachmentVars;

// hint LOC "$STR_REB_placement_released";