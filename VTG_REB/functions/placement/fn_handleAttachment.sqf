#include "..\defines.h"

params [["_object", objNull], ["_item", ""]];

if ((_object isEqualTo objNull) || (_object isEqualTo "")) exitWith {};

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

private _objectType = if (_object isEqualType "") then {_object} else {typeOf _object};

// new temporary object for preview
private _tempObject = createSimpleObject [_objectType, [0, 0, 0], true];

if (_tempObject isEqualTo objNull) exitWith {};

if (_object isEqualType objNull) then {
    // save old object
    if !(isNull (attachedTo _object)) then {
        detach _object;
    };
    [_object, false] remoteExec ["enableSimulationGlobal", 2];
    _object setPos [0,0,-5000];
    _player setVariable ["REB_currentAttachObj", _object];
};

_player setVariable ["REB_attachmentTempObj", _tempObject];
_player setVariable ["REB_currentAttachObjType", _objectType];
_player setVariable ["REB_currentAttachItem", _item];

if (_item != "") then {
    _player removeItem _item;
};

_player action ["SwitchWeapon", _player, _player, 100];
_player forceWalk true;

_tempObject disableCollisionWith _player;

// Attach action
REB_TEMP_placement_attachAction = [
    _player,
    "<t color='#0ed145'>Attach</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    '(vehicle player isEqualTo player) && (alive _target) && {!(isNull (player getVariable ["REB_attachmentTempObj", objNull])) && {(_this distance _target < 3)}}',
    '(vehicle player isEqualTo player) && (alive _target) && {!(isNull (player getVariable ["REB_attachmentTempObj", objNull])) && {(_this distance _target < 3)}}',
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
    nil, 1.5, true, true, "", '!(isNull (player getVariable ["REB_attachmentTempObj", objNull]))'
];

[_tempObject] call REB_fnc_updateAttachmentPosition;