#include "..\defines.h"

#define VEH_CHECK ([_vehOnlyForCrew, (_this select 1), (_this select 0)] call { params["_vehOnlyForCrew", "_plr", "_veh"]; if !(_vehOnlyForCrew) exitWith {true}; _plr in (crew _veh)})

params [
    "_object", 
    "_rebClassname", 
    "_objectRebHash", 
    "_canModifyStren", 
    "_canModifyRange", 
    "_objectRebName", 
    ["_vehOnlyForCrew", true], 
    ["_originObject", (_this select 0)]
];

PR _hashVal = _objectRebHash;

private _addToSelfActions = _object isKindOf "AllVehicles";

if ((getMass _object) < 100) then {
    if !(_object getVariable ["ace_dragging_canDrag", false]) then {
        [_object, true] call ace_dragging_fnc_setDraggable;
    };
    if !(_object getVariable ["ace_dragging_canCarry", false]) then {
        [_object, true] call ace_dragging_fnc_setCarryable;
    };
};

// 1. Создать главный REB action, если его ещё нет
private _mainActionId = _object getVariable ["REB_mainActionId", ""];

if (_mainActionId isEqualTo "") then {
    private _mainAction = [
        "REB_main",
        "REB",
        "",
        {},
        {true}
    ] call ace_interact_menu_fnc_createAction;

    private _mainActionId = [
        _object,
        0,
        ["ACE_MainActions"],
        _mainAction
    ] call ace_interact_menu_fnc_addActionToObject;

    // Если это транспорт, то добавляем действие в меню экипажа
    if (_addToSelfActions) then {
        private _selfActionId = [
            _object,
            1,
            ["ACE_SelfActions"],
            _mainAction
        ] call ace_interact_menu_fnc_addActionToObject;

        _object setVariable ["REB_selfActionId", _selfActionId];
    };

    _object setVariable ["REB_mainActionId", _mainActionId];
};

// 2. Получить displayName объекта для ветки object_reb
private _displayName = getText(configFile >> "CfgVehicles" >> typeOf _originObject >> "displayName");

// 3. Создать child actions для управления object_reb (глобально)
PR _actionDisable = [
    format ["REB_disable_%1", _rebClassname],
    LOC "$STR_REB_DISABLE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = MGVAR [(_params select 1), {}];
        [_objectReb, false] call REB_fnc_setActive;
    },
    {(_this select 2) params ["_object", "_objectRebName", "_hashVal", "_vehOnlyForCrew"]; _vehOnlyForCrew = _object getVariable [OBJ_VARPREF("vehActionsOnlyForCrew"), _vehOnlyForCrew]; (_object getVariable [OBJ_VARPREF("Is_active"), false]) && VEH_CHECK},
    {},
    [_originObject, _objectRebName, _objectRebHash, _vehOnlyForCrew]
] call ace_interact_menu_fnc_createAction;

PR _actionEnable = [
    format ["REB_enable_%1", _rebClassname],
    LOC "$STR_REB_ENABLE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = MGVAR [(_params select 1), {}];
        [_objectReb, true] call REB_fnc_setActive;
    },
    {(_this select 2) params ["_object", "_objectRebName", "_hashVal", "_vehOnlyForCrew"];_vehOnlyForCrew = _object getVariable [OBJ_VARPREF("vehActionsOnlyForCrew"), _vehOnlyForCrew]; !(_object getVariable [OBJ_VARPREF("Is_active"), false]) && VEH_CHECK},
    {},
    [_originObject, _objectRebName, _objectRebHash, _vehOnlyForCrew]
] call ace_interact_menu_fnc_createAction;

PR _actionSetRange = [
    format ["REB_setRange_%1", _rebClassname],
    LOC "$STR_REB_SET_RANGE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = MGVAR [(_params select 1), {}];
        [_objectReb] spawn REB_fnc_setRange;
    },
    {(_this select 2) params ["_object", "_objectRebName", "_hashVal", "_vehOnlyForCrew"]; _vehOnlyForCrew = _object getVariable [OBJ_VARPREF("vehActionsOnlyForCrew"), _vehOnlyForCrew]; (MGVAR ["REB_CanSetRangeGlobal", true]) && VEH_CHECK},
    {},
    [_originObject, _objectRebName, _objectRebHash, _vehOnlyForCrew]
] call ace_interact_menu_fnc_createAction;

PR _actionSetStrength = [
    format ["REB_setStrength_%1", _rebClassname],
    LOC "$STR_REB_SET_STRENGTH",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = MGVAR [(_params select 1), {}];
        [_objectReb] spawn REB_fnc_setStrenght;
    },
    {(_this select 2) params ["_object", "_objectRebName", "_hashVal", "_vehOnlyForCrew"]; _vehOnlyForCrew = _object getVariable [OBJ_VARPREF("vehActionsOnlyForCrew"), _vehOnlyForCrew]; (MGVAR ["REB_CanSetStrengthGlobal", false]) && VEH_CHECK},
    {},
    [_originObject, _objectRebName, _objectRebHash, _vehOnlyForCrew]
] call ace_interact_menu_fnc_createAction;

_object SV [OBJ_VARPREF('actionDisable'), _actionDisable];
_object SV [OBJ_VARPREF('actionEnable'), _actionEnable];
_object SV [OBJ_VARPREF('actionSetRange'), _actionSetRange];
_object SV [OBJ_VARPREF('actionSetStrength'), _actionSetStrength];
_object SV [OBJ_VARPREF('CanSetStrength'), _canModifyStren];
_object SV [OBJ_VARPREF('CanSetRange'), _canModifyRange];

// 4. Собрать ветку для object_reb (глобально)
PR _objectRebBranch = [
    format ["REB_branch_%1", _rebClassname],
    _displayName,
    "",
    {},
    {true},
    {
        params ["_target", ["_player", player], ["_params", []]];
        _params params ["_originObject", "_hashVal"];
        _acts = [
            _target GV (OBJ_VARPREF('actionDisable')),
            _target GV (OBJ_VARPREF('actionEnable'))
        ];
        if (_target GV [OBJ_VARPREF('CanSetStrength'), false]) then {
            _acts pushBack (_target GV (OBJ_VARPREF('actionSetStrength')));
        };
        if (_target GV [OBJ_VARPREF('CanSetRange'), false]) then {
            _acts pushBack (_target GV (OBJ_VARPREF('actionSetRange')));
        };
        _acts apply {
			[_x, [], _target]
		};
    },
    [_originObject, _objectRebHash]
] call ace_interact_menu_fnc_createAction;

// 5. Добавить ветку object_reb к главному REB action (через remoteExec)
private _objectRebActionMain = 
[
    _object,
    0,
    ["ACE_MainActions", "REB_main"],
    _objectRebBranch
];
private _objectRebActionMainId = _objectRebActionMain call ace_interact_menu_fnc_addActionToObject;

private _actions = [];

_actions pushBack _objectRebActionMainId;

if (_addToSelfActions) then {
    private _objectRebActionSelf = 
    [
        _object,
        1,
        ["ACE_SelfActions", "REB_main"],
        _objectRebBranch
    ];
    private _objectRebActionSelfId = _objectRebActionSelf call ace_interact_menu_fnc_addActionToObject;
    _actions pushBack _objectRebActionSelfId;
};

// 6. Сохраняем id actions object_reb'a для последующего удаления
_object setVariable ["REB_AceActions_" + _objectRebHash, _actions];

_actions