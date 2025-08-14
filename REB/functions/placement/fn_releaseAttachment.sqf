#include "..\defines.h"

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _object = _player getVariable ["REB_currentAttachObj", objNull];
private _objectType = _player getVariable ["REB_currentAttachObjType", ""];
private _item = _player getVariable ["REB_currentAttachItem", ""];
private _tempObj = _player getVariable ["REB_attachmentTempObj", objNull];

if (isNull _object) exitWith {};

// Если был item — возвращаем его игроку
if (_item != "") then {
    _player addItem _item;
};

PR _id = owner _object;

detach _object;
[_object, _player] remoteExec ["enableCollisionWith", _id];
[_object, true] remoteExec ["enableSimulationGlobal", _id];
_object setPosASL (getPosASL _tempObj);
[_object, [vectorDir _tempObj, vectorUp _tempObj]] remoteExec ["setVectorDirAndUp", _id];
deleteVehicle _tempObj;

// Очистка переменных
call REB_fnc_clearAttachmentVars;
