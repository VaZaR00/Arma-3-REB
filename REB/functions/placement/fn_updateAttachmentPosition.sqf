#include "..\defines.h"

params ["_object"];

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

private _attachFunction = {
    params ["_args", "_handle"];
    _args params ["_player", "_object"];

    private _currentPlayer = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    private _direction = getDirVisual _currentPlayer + 90;

    if (
        (isNull (player getVariable ["REB_attachmentTempObj", objnull])) ||
        vehicle _currentPlayer != _currentPlayer ||
        !alive _currentPlayer ||
        (_currentPlayer getVariable ["ACE_isUnconscious", false]) ||
        (lifeState _currentPlayer == "INCAPACITATED") ||
        (_player != _currentPlayer)
    ) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        [] call REB_fnc_releaseAttachment;
    };

    // if (isNil "REB_TEMP_updateNearCollisions") then {
    //     REB_TEMP_updateNearCollisions = [] spawn {
    //         private _currentPlayer = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    //         private _nearObjects = nearestObjects [_currentPlayer, [], 10];

    //         {
    //             if (isNull _x) exitWith {};
    //             if (alive _x && (_x != _currentPlayer)) then {
    //                 _x disableCollisionWith _currentPlayer;
    //                 _currentPlayer disableCollisionWith _x;
    //             };
    //         } forEach _nearObjects;
    //     };
    // };

    private _intersections = lineIntersectsSurfaces [
        AGLToASL positionCameraToWorld [0,0,0],
        AGLToASL positionCameraToWorld [0,0,2],
        _currentPlayer,
        _object,
        true,
        1,
        "GEOM",
        "NONE"
    ];

    _object setVariable ["REB_object_intersections", _intersections];
    _object setDir _direction;

    if (_intersections isEqualTo []) exitWith {
        _object setPosASL (_currentPlayer modelToWorldWorld [0, 1.5, 0.7]);
    };

    private _intersectObject = (_intersections # 0 # 2);
    private _collision = collisionDisabledWith _intersectObject;

    if ((isNull (_collision # 0)) && !(_collision # 1)) then {
        _object disableCollisionWith _intersectObject;
        _intersectObject disableCollisionWith _object;
    };

    _object setPosASL (_intersections # 0 # 0);
    _object setVectorUp (_intersections # 0 # 1);
};

[
    _attachFunction,
    0,
    [_player, _object]
] call CBA_fnc_addPerFrameHandler;