class CfgFunctions
{
	class REB
	{
		class scriptsREB
        {
			recompile=1;
            file = "VTG_REB\functions";
			class rebInit {};
			class compile {
				preInit = 1;
			};
			// class reb {};
			// class removeReb {};
			// class setRange {};
			// class setStrenght {};
		};
	};
	class DB
	{
		class saniaScripts
        {
			recompile=1;
            file = "VTG_REB\functions\sania";
			class playerActions_canAttach {};
			class playerActions_canPlace {};
			class playerActions_canRelease {};
			class addJammerToInventory {};
			class BackpackRemove {};
			class createJammer {};
			class disassembleToBackpack {};
			class jammerCanDisassembly {};
			class releaseJammer {};
			class updateJammerPos {};
		};
	};
};