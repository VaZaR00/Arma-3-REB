#include "defines.h"

// compile all functions
[] call REB_fnc_compile;

// we should spawn the init code because of waitUntil
_this spawn {

if (!(IS_ARR(_this)) || {!((_this#0) isEqualType false)}) then {
    _this = [];
};

params[["_forceInit", false, [false]], ["_freq", 0.1, [0]], ["_random", [0.3, 0.5, 1], [[]]]];

sleep 0.1; // wait for mission fully initialized

waitUntil { sleep 1; !isNil "REB_var_START_INIT"  };

#include "Classes\REB_DB.sqf"
#include "Classes\REB.sqf"
#include "Classes\OBJECT_REB.sqf"
#include "Classes\OBJECT_REB_DB.sqf"

if ((missionNamespace getVariable ["REB_var_INITED", false]) && !_forceInit) EX;

// main classes instantiation
IOO_REB_DB = NEW(OO_REB_DB, nil);
IOO_OBJECT_REB_DB = NEW(OO_OBJECT_REB_DB, nil);


REB_CanSetStrengthGlobal = true;
REB_CanSetRangeGlobal = true;
REB_systemIsOn = true;
REB_attachSystemOn = true;
REB_createUavCrewOnDisconectTime = 5;
REB_attach_actionTime = 0.5; // time in seconds for hold action to attach object

REB_var_rebItemsClasses = [];
REB_var_rebItemsSystemInited = false;
REB_freq = _freq;
REB_random = _random;
REB_delayInput = true;
REB_randomDelayInput = 0.5;

call REB_fnc_initEffects;

if (isNil "REB_ON_HANDLE_DRONE_EH") then {
    REB_ON_HANDLE_DRONE_EH = addMissionEventHandler ["PlayerViewChanged", {
        _this call REB_fnc_eventHandler;
    }];
};

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

if (MGVAR ["REB_var_testKeyInputDelay", false]) then {
    [] spawn REB_fnc_delayInputEventHandler;
};

MSVAR ["REB_var_INITED", true];

};