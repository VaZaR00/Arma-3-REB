private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

!isNull (_player getVariable ["DB_currentJammingObj", objNull]) &&
(vehicle _player == _player) &&
(alive _player)