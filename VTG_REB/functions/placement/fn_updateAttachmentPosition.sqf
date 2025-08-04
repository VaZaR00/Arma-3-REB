params ["_object"];

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

private _attachFunction = {
    params ["_args", "_handle"];
    _args params ["_player", "_object"];

    private _currentPlayer = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    private _direction = getDirVisual _currentPlayer + 90;

    if (
        (isNull (player getVariable ["REB_currentAttachObj", objnull])) ||
        vehicle _currentPlayer != _currentPlayer ||
        !alive _currentPlayer ||
        (_currentPlayer getVariable ["ACE_isUnconscious", false]) ||
        (lifeState _currentPlayer == "INCAPACITATED") ||
        (_player != _currentPlayer)
    ) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        [] call VTG_REB_fnc_REB_releaseAttachment;
    };

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
        _object setPosASL (_currentPlayer modelToWorldWorld [0, 1.5, 1.2]);
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