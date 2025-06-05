params ["_item", ""];

private _oldPlayer = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _objectType = ["Volnorez_1", "sania"] select (_item == "Item_JammerSania");
private _object = createSimpleObject [_objectType, [0, 0, 0], true];

_oldPlayer setVariable ["DB_currentJammingObj", _object];
_oldPlayer action ["SwitchWeapon", _oldPlayer, _oldPlayer, 100];
_oldPlayer allowSprint false;
_oldPlayer removeItem _item;

_object disableCollisionWith _oldPlayer;

private _function = {
	params ["_args", "_handle"];

	_args params ["_oldPlayer", "_object"];

	private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
	private _direction = getDirVisual _player + 90;

	if ((isNull _object) or (vehicle _player != _player) or (!alive _player) or (_player getVariable ["ACE_isUnconscious", false]) or (lifeState _player == "INCAPACITATED") or (_oldPlayer != _player)) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
		false call DB_fnc_releaseJammer;
	};

	private _intersections = lineIntersectsSurfaces [
		AGLToASL positionCameraToWorld [0,0,0],
		AGLToASL positionCameraToWorld [0,0,2],
		_player,
		_object,
		true,
		1,
		"GEOM",
		"NONE"
	];

	_object setVariable ["DB_jammer_intersections", _intersections];
	_object setDir _direction;

	if (_intersections isEqualTo []) exitWith {
		_object setPosASL (_player modelToWorldWorld [0, 1.5, 1.2]);
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
	_function, 
	0, 
	[_oldPlayer, _object]
] call CBA_fnc_addPerFrameHandler;