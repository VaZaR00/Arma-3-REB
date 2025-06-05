params ["_player", "_intensity"];

if (!local _player) exitWith {};

// Retrieve existing effects or create them with the specified priority
private _ppEffect = missionNameSpace getVariable ["DB_fpv_ppEffect", []];

// If there are existing effects, destroy them
if (_ppEffect isNotEqualTo []) then {
    {
        ppEffectDestroy _x;
    } forEach _ppEffect;
};

private _uav = getConnectedUAV _player;

// Find the strongest jammer affecting the UAV
private _maxSignalLoss = 0;
private _jammersNearUAV = nearestObjects [_uav, ["Sania", "Sania_with_tripod", "Volnorez_1"], 1200];

{
    private _jammerRange = _x getVariable ["DB_jammer_range", 1200];
    private _fullJamRadius = _jammerRange * 0.45;

    private _jammerLoss = _x getVariable ["DB_jammer_signalLoss", 0];
    private _uavDistance = _uav distance _x;

    if (_uavDistance <= _jammerRange) then {
        _maxSignalLoss = _maxSignalLoss max _jammerLoss;
        if (_uavDistance <= _fullJamRadius) then {
            _maxSignalLoss = 1;
        };
    };
} forEach _jammersNearUAV;

// Set intensity based on max signal loss
_intensity = _maxSignalLoss;

// Apply effects based on intensity
private _adjust = linearConversion [0, 1, _intensity, 0.1, 1.0];

// Create DynamicBlur effect
private _PP_dynamic = ppEffectCreate ["DynamicBlur", 500];
_PP_dynamic ppEffectEnable true;
_PP_dynamic ppEffectAdjust [[0.2, 1, _adjust] call BIS_fnc_lerp];
_PP_dynamic ppEffectCommit 0;

// Create FilmGrain effect
private _PP_film = ppEffectCreate ["FilmGrain", 2000];
_PP_film ppEffectEnable true;
_PP_film ppEffectAdjust [
    [[0.04, 4, _adjust] call BIS_fnc_lerp, 1],
    [2.09, 4.5, _adjust] call BIS_fnc_lerp,
    0.5,
    0.5,
    true
];
_PP_film ppEffectCommit 0;

// **Create Thermal Jamming Effect (RadialBlur)**
private _PP_thermal = ppEffectCreate ["RadialBlur", 1000];
_PP_thermal ppEffectEnable false;  // Initially disabled
_PP_thermal ppEffectAdjust [0, 0, 0, 0];
_PP_thermal ppEffectCommit 0;

// Store all effects for later removal or modification
missionNameSpace setVariable ["DB_fpv_ppEffect", [_PP_dynamic, _PP_film, _PP_thermal]];

// **Loop to monitor jamming & thermal vision mode**
[ _player, _uav, _intensity, [_PP_dynamic, _PP_film, _PP_thermal] ] spawn {
    params ["_player", "_uav", "_intensity", "_effects"];
    private _PP_dynamic = _effects select 0;
    private _PP_film = _effects select 1;
    private _PP_thermal = _effects select 2;

    private _lastUpdate = time;
    private _lastVisionMode = currentVisionMode player;

    while { 
        !isNull _uav && { alive _uav } && { cameraOn == _uav }
    } do {
        private _oldIntensity = _intensity;
        _intensity = _uav getVariable ["DB_jammer_signalLoss", 0];

        // Detect change in intensity and reset timeout
        if (_intensity != _oldIntensity) then {
            _lastUpdate = time;
        };

        // **Check Thermal Vision Mode**
        private _currentVisionMode = currentVisionMode player;
        if (_currentVisionMode != _lastVisionMode) then {
            _lastVisionMode = _currentVisionMode;
        };

        // **Enable Thermal Effect if in TI mode (2 or 3)**
        if (_currentVisionMode in [2, 3]) then {
            _PP_thermal ppEffectEnable true;
            _PP_thermal ppEffectAdjust [0.2 + (_intensity * 0.6), 0.3, 0.5, 0.5]; // Increase blur based on jamming intensity
            _PP_thermal ppEffectCommit 0;
        } else {
            _PP_thermal ppEffectEnable false;
            _PP_thermal ppEffectCommit 0;
        };

        // If no update for 5 seconds, force intensity to 0 and exit
        if ((time - _lastUpdate) > 5) exitWith { 
            _intensity = 0;
            break;
        };

        sleep 1;
    };

    // Remove effects when loop exits
    {
        _x ppEffectEnable false;
        ppEffectDestroy _x;
    } forEach _effects;

    // Clear stored effects
    missionNameSpace setVariable ["DB_fpv_ppEffect", []];
};
