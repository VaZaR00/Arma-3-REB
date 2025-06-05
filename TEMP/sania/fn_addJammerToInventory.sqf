params ["_jammer"];

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _jammerType = toUpper (typeOf _jammer);
private _item = ["Item_JammerVolnorez", "Item_JammerSania"] select ((_jammerType find "SANIA") >= 0);

_player addItem _item;
_player action ["TakeBag", objNull];

deleteVehicle _jammer;