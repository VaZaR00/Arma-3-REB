#include "defines.h"

#include "Classes\REB_DB.sqf"
#include "Classes\REB.sqf"
#include "Classes\OBJECT_REB.sqf"
#include "Classes\OBJECT_REB_DB.sqf"
#include "Classes\test_oop.sqf"

IOO_REB_DB = NEW(OO_REB_DB, nil);
IOO_OBJECT_REB_DB = NEW(OO_OBJECT_REB_DB, nil);

REB_var_rebItemsSystemInited = false;
REB_createUavCrewOnDisconectTime = 5;
REB_var_rebItemsClasses = [];

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

// call REB_fnc_aceActions;

MSVAR ["REB_var_INITED", true];