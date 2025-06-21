#include "defines.h"

#include 

if !(isNil "REB_ON_HANDLE_DRONE_EH") then {
	removeMissionEventHandler ["PlayerViewChanged", REB_ON_HANDLE_DRONE_EH];
};

// Define main variables
REB_all_rebs = [];
REB_all_classes = createHashMap;
REB_var_rebItemsSystemInited = false;

REB_createUavCrewOnDisconectTime = 5;

PR _defaultRandom = [0.3, 0.5, 1];
REB_freq = param[0, 0.1];
REB_random = param[1, _defaultRandom];
REB_noise = ppEffectCreate ["FilmGrain",3000];


REB_ON_HANDLE_DRONE_EH = addMissionEventHandler ["PlayerViewChanged", {
	_this call REB_fnc_eventHandler;
}];

call REB_fnc_aceActions;

MSVAR ["REB_var_INITED", true];