params [["_isAdd", true]];

private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _jammer = _player getVariable ["DB_currentJammingObj", objNull];

private _jammerType = toUpper (typeOf _jammer);
private _item = ["Item_JammerVolnorez", "Item_JammerSania"] select ((_jammerType find "SANIA") >= 0);

deleteVehicle _jammer;

_player setVariable ["DB_currentJammingObj", nil];
_player action ["WeaponInHand", _player];
_player allowSprint true;

if (_isAdd) then {
    _player addItem _item;
};