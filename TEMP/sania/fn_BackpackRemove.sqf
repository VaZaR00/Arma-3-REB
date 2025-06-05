// DB_fnc_BackpackRemove.sqf

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
if (isNull _player) exitWith {};

private _bp = backpack _player;
private _jammerBackpacks = ["Sania_Bag", "Volnorez_Bag"];

if (_bp in _jammerBackpacks) then {
    removeBackpackGlobal _player;
};
