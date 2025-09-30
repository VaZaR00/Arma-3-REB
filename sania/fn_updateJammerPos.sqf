params ["_item", ""];

private _objectType = ["Volnorez_1", "sania"] select (_item == "Item_JammerSania");

[_objectType] call REB_fnc_handleObjectAttachment;