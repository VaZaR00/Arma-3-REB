class CfgFunctions
{
	class PREFX
	{
		class scripts##PREFX
        {
			recompile=1;
            file = CFG_FUNCTIONS_PATH;
			class rebInit { postInit = 1; };
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
            file = CFG_FUNCTIONS_PATH_FOLDER(placement);
			class releaseAttachment {};
			class updateAttachmentPosition {};	
			class placeAttachment {};
			class handleAttachment {};
			class clearAttachmentVars {};
			class setAttachable {};
			class attachObject {};
			class canManipulateAce {};
		};
		class ace_actions
		{
			recompile=1;
			file = CFG_FUNCTIONS_PATH_FOLDER(ace_actions);
			class createAceActionsForObjectReb {};
			class removeAceActionsForObjectReb {};
			class objectRemoveAceActions {};
		};
	};
};