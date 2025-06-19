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

REB_aceMenuAction_toggleReb = ["REB_toggleReb", "$STR_REB_DISABLE", "", {[_target] call REB_fnc_toggleReb;}, {true}, {}, [parameters], [0, 0, 0], 100] call ace_interact_menu_fnc_createAction;
REB_aceMenuAction_setRange = ["REB_setRange", "$STR_REB_SET_RANGE", "", {[_target] call REB_fnc_setRange;}, {true}, {}, [parameters], [0, 0, 0], 100] call ace_interact_menu_fnc_createAction;
REB_aceMenuAction_setStrenght = ["REB_setStrenght", "$STR_REB_SET_STRENGHT", "", {[_target] call REB_fnc_setStrenght;}, {true}, {}, [parameters], [0, 0, 0], 100] call ace_interact_menu_fnc_createAction;

MSVAR ["REB_var_INITED", true];