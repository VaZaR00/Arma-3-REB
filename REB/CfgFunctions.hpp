class CfgFunctions
{
	class REB
	{
		class scriptsREB
        {
			recompile=1;
            file = "REB\functions";
			class rebInit {};
			class compile {};
			class reb {};
			class removeReb {};
			class setRange {};
			class setStrenght {};
			class setValueDialog {};
			class remoteCall {};
		};
		class REBplacement
        {
			recompile=1;
            file = "REB\functions\placement";
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
			file = "REB\functions\ace_actions";
			class createAceActionsForObjectReb {};
			class removeAceActionsForObjectReb {};
		};
	};
};