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
			class reb {};
			class removeReb {};
			class setRange {};
			class setStrenght {};
			class setValueDialog {};
		};
		class REBplacement
        {
			recompile=1;
            file = "VTG_REB\functions\placement";
			class releaseAttachment {};
			class updateAttachmentPosition {};	
			class placeAttachment {};
			class handleAttachment {};
			class clearAttachmentVars {};
			class setAttachable {};
		};
		class ace_actions
		{
			recompile=1;
			file = "VTG_REB\functions\ace_actions";
			class createAceActionsForObjectReb {};
			class removeAceActionsForObjectReb {};
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