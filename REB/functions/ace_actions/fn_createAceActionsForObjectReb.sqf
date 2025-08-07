/*
    [object_reb_instance] call REB_fnc_createAceActionsForObjectReb;
    - object_reb_instance: инстанс OO_OBJECT_REB
*/

#include "..\defines.h"

FILE_ONLY_SPAWN

params ["_objectReb"];

["ACE_CRT_ACTS_1", _objectReb] RLOG

_this = _objectReb;
GET_SERVER_VAL INSTANCE_VAR(_this, "Object"); 
GSRES(private _object);
GET_SERVER_VAL INSTANCE_VAR(_this, "Reb_classname"); 
GSRES(private _rebClassname);
GET_SERVER_VAL INSTANCE_VAR(_this, "InstanceHash"); 
GSRES(private _objectRebHash);

["ACE_CRT_ACTS_2", _object] RLOG

private _addToSelfActions = _object isKindOf "LandVehicle";

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
private _displayName = getText(configFile >> "CfgVehicles" >> typeOf _object >> "displayName");

// 3. Создать child actions для управления object_reb (глобально)
PR _actionDisable = [
    format ["REB_disable_%1", _rebClassname],
    LOC "$STR_REB_DISABLE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = _params select 0;
        [_objectReb, false] call REB_fnc_setActive;
    },
    {((_this select 0) getVariable [format["REB_var_OBJECT_REB_IS_ACTIVE_%1", ((_this select 2) select 1)], false])},
    {},
    [_objectReb, _objectRebHash]
] call ace_interact_menu_fnc_createAction;

PR _actionEnable = [
    format ["REB_enable_%1", _rebClassname],
    LOC "$STR_REB_ENABLE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = _params select 0;
        [_objectReb, true] call REB_fnc_setActive;
    },
    {!((_this select 0) getVariable [format["REB_var_OBJECT_REB_IS_ACTIVE_%1", ((_this select 2) select 1)], false])},
    {},
    [_objectReb, _objectRebHash]
] call ace_interact_menu_fnc_createAction;

PR _actionSetRange = [
    format ["REB_setRange_%1", _rebClassname],
    LOC "$STR_REB_SET_RANGE",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = _params select 0;
        [_objectReb] spawn REB_fnc_setRange;
    },
    {true},
    {},
    [_objectReb]
] call ace_interact_menu_fnc_createAction;

PR _actionSetStrength = [
    format ["REB_setStrength_%1", _rebClassname],
    LOC "$STR_REB_SET_STRENGTH",
    "",
    {
        params ["_target", "_player", "_params"];
        private _objectReb = _params select 0;
        [_objectReb] spawn REB_fnc_setStrenght;
    },
    {true},
    {},
    [_objectReb]
] call ace_interact_menu_fnc_createAction;

_object SV ["REB_actionDisable", _actionDisable];
_object SV ["REB_actionEnable", _actionEnable];
_object SV ["REB_actionSetRange", _actionSetRange];
_object SV ["REB_actionSetStrength", _actionSetStrength];

// 4. Собрать ветку для object_reb (глобально)
PR _objectRebBranch = [
    format ["REB_branch_%1", _rebClassname],
    _displayName,
    "",
    {},
    {true},
    {
        params ["_target", ["_player", player], ["_params", []]];
        [
            _target GV "REB_actionDisable",
            _target GV "REB_actionEnable",
            _target GV "REB_actionSetRange",
            _target GV "REB_actionSetStrength"
        ] apply {
			[_x, [], _target]
		};
    },
    [_objectReb]
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

["ACE_CRT_ACTS_3", _object, _actions] RLOG

_actions