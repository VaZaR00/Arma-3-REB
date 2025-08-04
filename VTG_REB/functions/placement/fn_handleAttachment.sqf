params [["_object", objNull], ["_item", ""]];

if ((_object isEqualTo objNull) || (_object isEqualTo "")) exitWith {};

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

private _objectType = _object;

if (_object isEqualType "") then {
    _object = createSimpleObject [_objectType, [0, 0, 0], true];
    if !(_object isEqualTo objNull) then {
        _player setVariable ["REB_attachmentTempObj", _object];
    };
} else {
    if !(isNull (attachedTo _object)) then {
        detach _object;
    };
    _objectType = typeOf _object;
};

if (_object isEqualTo objNull) exitWith {};

_player setVariable ["REB_currentAttachObj", _object];
_player setVariable ["REB_currentAttachObjType", _objectType];
_player setVariable ["REB_currentAttachItem", _item];

if (_item != "") then {
    _player removeItem _item;
};

_player action ["SwitchWeapon", _player, _player, 100];
_player forceWalk true;

_object disableCollisionWith _player;

// Attach action
REB_TEMP_placement_attachAction = [
    _player,
    "<t color='#0ed145'>Attach</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    '(alive _target) && {!(isNull (player getVariable ["REB_currentAttachObj", objNull])) && {(_this distance _target < 3)}}',
    '(alive _target) && {!(isNull (player getVariable ["REB_currentAttachObj", objNull])) && {(_this distance _target < 3)}}',
    {},
    {},
    { call REB_fnc_placeAttachment; },
    {},
    [],
    (missionNamespace getVariable ["REB_attach_actionTime", 5]),
    0,
    false,
    false
] call BIS_fnc_holdActionAdd;

// Release action
REB_TEMP_placement_releaseAction = _player addAction [
    "<t color='#ec1c24'>Release</t>",
    {
        call REB_fnc_releaseAttachment;
    },
    nil, 1.5, true, true, "", '!(isNull (player getVariable ["REB_currentAttachObj", objNull]))'
];

[_object] call REB_fnc_updateAttachmentPosition;