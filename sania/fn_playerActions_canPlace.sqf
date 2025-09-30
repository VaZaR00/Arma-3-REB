params ["_jammerType", ""];

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

// Convert item to backpack class if needed
private _backpackMap = [
    ["Item_JammerSania", "Sania_Bag"],
    ["Item_JammerVolnorez", "Volnorez_Bag"]
];

private _backpackClass = (_backpackMap select { _x#0 == _jammerType }) param [0, []] param [1, ""];

// Check if player has the item
private _hasItem = [_player, _jammerType] call BIS_fnc_hasItem;

// Check if player has the backpack version equipped
private _hasBackpack = (backpack _player) == _backpackClass;

(isNull (_player getVariable ["DB_currentJammingObj", objNull])) &&
(vehicle _player == _player) &&
(alive _player) &&
(_hasItem || _hasBackpack)
