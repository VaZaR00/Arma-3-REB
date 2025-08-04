private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _object = _player getVariable ["REB_currentAttachObj", objNull];
private _objectType = _player getVariable ["REB_currentAttachObjType", ""];
private _item = _player getVariable ["REB_currentAttachItem", ""];
private _tempObj = _player getVariable ["REB_attachmentTempObj", objNull];

if (isNull _object) exitWith {};

private _intersections = _object getVariable ["REB_object_intersections", []];
private _position = _intersections # 0 # 0;
private _intersectObject = _intersections # 0 # 2;
private _intersectObjectType = "";
private _vectorDirAndUp = [vectorDir _object, vectorUp _object];

// Очистка переменных
call REB_fnc_clearAttachmentVars;

if (!isNil "_intersectObject") then {
    _intersectObjectType = (_intersectObject call BIS_fnc_objectType) # 0;
};

if ((_intersections isEqualTo []) or (_intersectObjectType == "Soldier")) exitWith {
    hintSilent "Cannot place";
};

if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
    _vectorDirAndUp = [_object, _intersectObject] call BIS_fnc_vectorDirAndUpRelative;
};

// Если объект временный (созданный по классу), создаём финальный объект
if (!isNull _tempObj) then {
    deleteVehicle _object;
    _object = _objectType createVehicle [0, 0, 0];
};

// Привязываем к технике или ставим на землю
if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
    _object attachTo [_intersectObject, _intersectObject worldToModel (ASLToAGL _position)];
    _intersectObject setVariable ["REB_object_attachedObject", _object, true];
    _intersectObject addEventHandler ["Killed", {
        params ["_object"];
        deleteVehicle (_object getVariable ["REB_object_attachedObject", objNull]);
        _object setVariable ["REB_object_attachedObject", nil, true];
        _object removeEventHandler ["Killed", _thisEventHandler];
    }];
};

if (isNull attachedTo _object) then {
    [_object, false] remoteExec ["enableSimulationGlobal", 2];
    _object setPosASL _position;
};

_object setVariable ["REB_object_isActive", true, true];
_object setVectorDirAndUp _vectorDirAndUp;