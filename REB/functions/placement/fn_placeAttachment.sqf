#include "..\defines.h"

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _object = _player getVariable ["REB_currentAttachObj", objNull];
private _objectType = _player getVariable ["REB_currentAttachObjType", ""];
private _item = _player getVariable ["REB_currentAttachItem", ""];
private _tempObj = _player getVariable ["REB_attachmentTempObj", objNull];

if (isNull _tempObj) exitWith {};

private _intersections = _tempObj getVariable ["REB_object_intersections", []];

private _position = _intersections # 0 # 0;
private _intersectObject = _intersections # 0 # 2;
private _selection = _intersections # 0 # 4 # 0;
private _intersectObjectType = "";
private _vectorDirAndUp = [vectorDir _tempObj, vectorUp _tempObj];


if (!isNil "_intersectObject") then {
    _intersectObjectType = (_intersectObject call BIS_fnc_objectType) # 0;
};

if (
    ((_intersections isEqualTo []) or (_intersectObjectType == "Soldier")) ||
    !(_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"])
) exitWith {
    hintSilent LOC "$STR_REB_placement_cannotPlace";
};

_vectorDirAndUp = [_tempObj, _intersectObject] call BIS_fnc_vectorDirAndUpRelative;

// Привязываем к технике или ставим на землю
[_object, _tempObj, _intersections] remoteExec ["REB_fnc_attachObject", IF_ELSE(owner _object == 0, 2, owner _object)];

// Очистка переменных
call REB_fnc_clearAttachmentVars;

hint LOC "$STR_REB_placement_placed";