class CfgPatches {
	class REB {
		name = "VTG REB";
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

#include "CfgFunctions.hpp"
#include "CfgRemoteExec.hpp"