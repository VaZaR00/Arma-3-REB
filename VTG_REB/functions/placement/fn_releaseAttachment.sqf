private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _object = _player getVariable ["REB_currentAttachObj", objNull];
private _objectType = _player getVariable ["REB_currentAttachObjType", ""];
private _item = _player getVariable ["REB_currentAttachItem", ""];
private _tempObj = _player getVariable ["REB_attachmentTempObj", objNull];

// Очистка переменных
call REB_fnc_clearAttachmentVars;

if (!isNull _object) then {
    // Если это временный объект — удаляем его
    if (!isNull _tempObj) then {
        deleteVehicle _object;
        // Если был item — возвращаем его игроку
        if (_item != "") then {
            _player addItem _item;
        };
    } else {
        _object enableCollisionWith _player;
        private _dir = getDir _player;
        private _pos = _player modelToWorld [0,1.5,0]; // 1.5 метра перед игроком на уровне рук
        _object setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];
    };
};