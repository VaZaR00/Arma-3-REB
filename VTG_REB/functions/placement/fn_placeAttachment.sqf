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

// Очистка переменных
call REB_fnc_clearAttachmentVars;

if (!isNil "_intersectObject") then {
    _intersectObjectType = (_intersectObject call BIS_fnc_objectType) # 0;
};

if ((_intersections isEqualTo []) or (_intersectObjectType == "Soldier")) exitWith {
    hintSilent "Cannot place";
};

if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
    _vectorDirAndUp = [_tempObj, _intersectObject] call BIS_fnc_vectorDirAndUpRelative;
};

// Привязываем к технике или ставим на землю
if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
    private _origPos = getPosASL _tempObj;
    _object setPosASL _origPos;
    _object setVectorDirAndUp _vectorDirAndUp;

    // Если есть селекция, то крепим к ней
    if (!(isNil "_selection") && {!(_selection isEqualTo "")}) then {
        private _tempSelectionObj = _intersectObject getVariable [("REB_TempObj_selection_" + _selection), objNull];
        if (isNull _tempSelectionObj) then {
            _tempSelectionObj = "Weapon_Empty" createVehicle [0, 0, 0];
            _tempSelectionObj attachTo [_intersectObject, [0, 0, 0], _selection, true];
            _intersectObject setVariable [("REB_TempObj_selection_" + _selection), _tempSelectionObj, true];
        };
        [_object, _tempSelectionObj] call BIS_fnc_attachToRelative;
    } else {
        [_object, _intersectObject] call BIS_fnc_attachToRelative;
    };

    deleteVehicle _tempObj;
    [_object, true] remoteExec ["enableSimulationGlobal", 2];

    // _object attachTo [_intersectObject, _intersectObject worldToModel (ASLToAGL _position)];
    _intersectObject setVariable ["REB_object_attachedObject", _object, true];
    [_intersectObject, ["Killed", {
        params ["_object"];
        if (not local _object) exitWith {};
        private _attachedObject = _object getVariable ["REB_object_attachedObject", objNull];
        if (isNull _attachedObject) exitWith {};
        deleteVehicle _attachedObject;
        _object setVariable ["REB_object_attachedObject", nil, true];
    }]] remoteExec ["addEventHandler", 0, true];

    private _aceEventCode = {
        params ["_unit", "_target"];
        if !(_target isEqualTo _thisArgs) exitWith {};
        _thisArgs setVariable ["REB_object_attachedObject", nil, true];
    };
    ["ace_dragging_startedCarry", _aceEventCode, _object] remoteExec ["CBA_fnc_addEventHandlerArgs", 0, true];
    ["ace_dragging_startedDrag", _aceEventCode, _object] remoteExec ["CBA_fnc_addEventHandlerArgs", 0, true];
};

hint LOC "$STR_REB_placement_placed";