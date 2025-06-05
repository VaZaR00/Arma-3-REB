
params ["_uav", "_player"];

// if is in drone
if (cameraOn == _uav) then {
	// Credits for Sa-Matra
	{ _freeze_until = diag_tickTime + 3.0; for "_i" from 1 to 2 do {_i = [1,2] select (diag_tickTime > _freeze_until);};  } call CBA_fnc_directCall;
};

_player connectTerminalToUAV objNull;
(driver _uav) setDamage 1;
(gunner _uav) setDamage 1;
