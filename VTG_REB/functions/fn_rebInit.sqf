#include "defines.h"

#include "Classes\REB_DB.sqf"
#include "Classes\REB.sqf"
#include "Classes\OBJECT_REB.sqf"
#include "Classes\OBJECT_REB_DB.sqf"

// main classes instanciation
if (isServer) then {
    IOO_REB_DB = NEW(OO_REB_DB, nil);
    IOO_OBJECT_REB_DB = NEW(OO_OBJECT_REB_DB, nil);
};

REB_var_rebItemsSystemInited = false;
REB_createUavCrewOnDisconectTime = 5;
REB_var_rebItemsClasses = [];
REB_attach_actionTime = 0.5; // time in seconds for hold action to attach object

PR _defaultRandom = [0.3, 0.5, 1];
REB_freq = param[0, 0.1];
REB_random = param[1, _defaultRandom];
REB_noise = ppEffectCreate ["FilmGrain",3000];

if !(isNil "REB_ON_HANDLE_DRONE_EH") then {
	removeMissionEventHandler ["PlayerViewChanged", REB_ON_HANDLE_DRONE_EH];
};
REB_ON_HANDLE_DRONE_EH = addMissionEventHandler ["PlayerViewChanged", {
	_this call REB_fnc_eventHandler;
}];

[] spawn {  
    if !(isNil "REB_ON_KeyDown_EH") exitWith {};

    waitUntil { !isNull findDisplay 46 };

    REB_ON_KeyDown_EH = findDisplay 46 displayAddEventHandler ["KeyDown", {
        private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    
        if (isNull (_player getVariable ["REB_attachmentTempObj", objNull])) exitWith {};

        private _lockedActions = ["binocular", "SwitchPrimary", "SwitchHandgun", "SwitchSecondary", "SwitchWeaponGrp1", "SwitchWeaponGrp2", "SwitchWeaponGrp3", "SwitchWeaponGrp4", "throw"];

        if (_lockedActions findIf { (inputAction _x) != 0 } != -1) then {
            true;
        };
    }];
};

call REB_fnc_compile;

MSVAR ["REB_var_INITED", true];