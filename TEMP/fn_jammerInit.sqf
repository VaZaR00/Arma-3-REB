params ["_jammer"];

if (is3DEN) exitWith {};
if !(isServer) exitWith {};

_jammer setMass 100;
_jammer setVariable ["DB_jammer_isActive", true, true];

_jammer addEventHandler ["Killed", {
    params ["_jammer"];
    _jammer removeEventHandler ["Killed", _thisEventHandler];
    _jammer setVariable ["DB_jammer_isActive", nil, true];
    deleteVehicle _jammer;
}];

// Scan function
private _function = {
    params ["_args", "_handle"];
    private _jammer = _args # 0;

    if (!alive _jammer) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
    if !(_jammer getVariable ["DB_jammer_isActive", false]) exitWith {};

    private _maxJamDistance = _jammer getVariable ["DB_Jammer_range", 300];

    // Detect range change
    private _lastJamDistance = _jammer getVariable ["DB_Jammer_lastRange", 300];
    if (_maxJamDistance != _lastJamDistance) then {
        _jammer setVariable ["DB_Jammer_lastRange", _maxJamDistance, true];

        // Force UAVs outside new range to reset
        {
            private _uav = _x;
            private _distance = _uav distance _jammer;

            if (_distance > _maxJamDistance) then {
                _uav setVariable ["DB_jammer_signalLoss", 0, true];
            };
        } forEach allUnitsUAV;
    };

    private _fullJamRadius = _maxJamDistance * 0.45;
    private _partialJamRadius = _maxJamDistance;

    private _nearUavs = allUnitsUAV select {
        ((_x distance _jammer) < _partialJamRadius) &&
        { alive _x } &&
        { !(isObjectHidden _x) } &&
        { isEngineOn _x }
    };

    if (_nearUavs isEqualTo []) exitWith {};

    {
        private _uav = _x;
        private _uavUnit = (UAVControl _uav) # 0;
        private _connectedUAVType = typeOf _uav;
		private _dronesArraySS = ["O_Crocus_AT", "O_Crocus_AP", "B_Crocus_AT", "B_Crocus_AP", "I_Crocus_AT", "I_Crocus_AP"];

        private _isCustomBehavior = _uav getVariable ["DB_jammer_customUavBehavior", false];
        private _uavDistance = _uav distance _jammer;

        if (_uavDistance < _fullJamRadius) then {
            // Full jamming (Complete signal loss)
            _uav setVariable ["DB_jammer_signalLoss", 1, true];

            if (isPlayer _uavUnit) then {
                if (!_isCustomBehavior) then {
                    [_uav, _uavUnit] remoteExecCall ["DB_fnc_jammerUavDisable", _uavUnit];
                };
            } else {
                (driver _uav) setDamage 1;
                (gunner _uav) setDamage 1;
            };
        } else {
            // Partial jamming - Calculate signal loss
            private _signalLossFactor = 1 - ((_uavDistance - _fullJamRadius) / (_partialJamRadius - _fullJamRadius));  
            _signalLossFactor = _signalLossFactor max 0 min 1;

            _uav setVariable ["DB_jammer_signalLoss", _signalLossFactor, true];
			_jammer setVariable ["DB_jammer_signalLoss", _signalLossFactor, true];

            // Apply post-processing for UAV pilots *only if the UAV is NOT a Crocus drone*
            if (!isNull _uavUnit && isPlayer _uavUnit && !(_connectedUAVType in _dronesArraySS)) then {  
                [_uavUnit, _signalLossFactor] remoteExecCall ["DB_fnc_jammerApplyPP", _uavUnit];
            };
        };
    } forEach _nearUavs;
};

// Add PerFrameHandler
[_function, 0.5, [_jammer]] call CBA_fnc_addPerFrameHandler;
