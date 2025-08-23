class CfgPatches {
	class REB {
		name = "REB";
		author = "Vazar";
		requiredAddons[] = {
			"A3_Functions_F",
			"cba_common"
		};
		units[] = {};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#include "includes\main.h"
#include "includes\CfgFunctions.hpp"
#include "includes\CfgRemoteExec.hpp"