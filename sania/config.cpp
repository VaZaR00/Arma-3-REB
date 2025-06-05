class CfgPatches
{
	class sania_antiuav
	{
		units[]=
		{
			"Podavitel",
			"Sania",
			"Sania_with_tripod",
			"Volnorez_1",
			"Volnorez_Bag",
			"Sania_Crate",
			"Sania_Bag",
			"VTG_REB"
		};
		weapons[]={};
		requiredVersion=1.03;
		version=1.14;
		requiredAddons[]=
		{
			"cba_xeh",
			"ArmaFPV_Data"
		};
		author="sam and DarkBall feat. Furi_, edited by Vazar";
	};
};

#include "includes\CfgFunctions.hpp"
#include "includes\CfgMagazines.hpp"
#include "includes\CfgVehicles.hpp"
#include "includes\Extended_ClientInit_EventHandlers.hpp"
#include "includes\Extended_InitPost_EventHandlers.hpp"
#include "includes\Extended_PreInit_EventHandlers.hpp"

class cfgMods
{
	author="Sam";
	timepacked="1708634670";
};
