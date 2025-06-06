#include "defines.h"
#define ISLANCET ("lancet_tripod_launcher" in (typeOf vehicle player))
#define ISLANCETHANDL (ISLANCET && dialog)
#define NGVAR _namespace getVariable

if !(isNil "REB_ON_HANDLE_DRONE_EH") then {
	removeMissionEventHandler ["PlayerViewChanged", REB_ON_HANDLE_DRONE_EH];
};

// Define main variables
REB_all_rebs = [];
REB_all_hashes = createHashMap;
REB_var_rebItemsSystemInited = false;

PR _defaultRandom = [0.3, 0.5, 1];
PR _freq = param[0, 0.1];
PR _random = param[1, _defaultRandom];
PR _noise = ppEffectCreate ["FilmGrain",3000];


REB_ON_HANDLE_DRONE_EH = addMissionEventHandler ["PlayerViewChanged", {
	[_this, _thisArgs] call REB_fnc_eventHandler;
}, [_freq, _random, _noise]];

MSVAR ["REB_var_INITED", true];