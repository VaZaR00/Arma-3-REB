{#line 20 "\z\ace\addons\interact_menu\functions\fnc_removeActionFromObject.sqf"
params ["_object", "_typeNum", "_fullPath"];

private _res = _fullPath call ace_interact_menu_fnc_splitPath;
_res params ["_parentPath", "_actionName"];

private _varName = ["ace_interact_menu_actions","ace_interact_menu_selfActions"] select _typeNum;
private _actionList = _object getVariable [_varName, []];
{
    if (((_x select 0) select 0) isEqualTo _actionName &&
        {(_x select 1) isEqualTo _parentPath}) exitWith {
        _actionList deleteAt _forEachIndex;
    };
} forEach _actionList;
}