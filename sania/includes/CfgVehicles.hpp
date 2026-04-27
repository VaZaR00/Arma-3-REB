#define STR_PREF STR_REB_Module_Device_
#define STR(s) #s
#define PREF(s) REB_##s
#define SPREF(s) STR(PREF(s))
#define SSTR_N(s) $##STR_PREF##s
#define SSTR_DESC_N(s) $##STR_PREF##DESC_##s
#define SSTR(s) STR(SSTR_N(s))
#define SSTR_DESC(s) STR(SSTR_DESC_N(s))
#define TRIPPLE(s1,s2,s3) s1##s2##s3
#define STRSYM "
#define STRIPPLE(s1,s2,s3) STRSYM##s1##s2##s3##STRSYM

#define SVAR _this setVariable ['
#define PBSVAL ', (_value isEqualTo 1), true];
#define PSVAL ', _value, true];

#define PARAMETER_BOOL(paramName, default) class PREF(paramName) \
{ \
	displayName = SSTR(paramName); \
	tooltip = SSTR_DESC(paramName); \
	property = SPREF(paramName); \
	control = "CheckboxNumber"; \
	expression = STRIPPLE(SVAR,paramName,PBSVAL); \
	defaultValue = STR(default); \
	validate = "number";  \
};

#define PARAMETER(paramName, default) class PREF(paramName) \
{ \
	displayName = SSTR(paramName); \
	tooltip = SSTR_DESC(paramName); \
	property = SPREF(paramName); \
	control = "EditShort"; \
	expression = STRIPPLE(SVAR,paramName,PSVAL); \
	defaultValue = default; \
	validate = "none";  \
};

class CfgVehicleClasses
{
    class sania_podavitel
    {
        displayName="REB";
    };

	// class volnorez_podavitel : sania_podavitel
    // {
    //     displayName="REB";
    // };
};
class CfgFactionClasses
{
        class sania_model
        {
               displayName = "REB Sania";                        // Name based on the editor faction class.
               priority = 1;
               side = 2;                                              // Group association.
        };
};
class CfgVehicles
{
	class ThingX;	// External class reference
	class Sania_Base : ThingX
	{
		cost = 0;
		armor = 100;
		destrType = "DestructDefault";
		placement = vertical;
		mapSize = 3;

		class UserActions
		{
		};
        class Attributes
        {
            PARAMETER(Radius,"100")
            PARAMETER(Deadzone,"30")
            PARAMETER(Strength,"0.5")
            PARAMETER_BOOL(IsAttachable,0)
            PARAMETER_BOOL(CanModifyRange,1)
            PARAMETER_BOOL(CanModifyStrength,0)
            PARAMETER_BOOL(IsActive,1)
            PARAMETER(linkedObjects,"")
        };

		// Dragging
        ace_dragging_canDrag = 1;  // Can be dragged (0-no, 1-yes)
        ace_dragging_dragPosition[] = {0, 1.2, 0};  // Offset of the model from the body while dragging (same as attachTo) (default: [0, 1.5, 0])
        ace_dragging_dragDirection = 90;  // Model direction while dragging (same as setDir after attachTo) (default: 0)
        ace_dragging_ignoreWeight = 1; // Ignore weight limitation for dragging (0-no, 1-yes)

        // Carrying
        ace_dragging_canCarry = 1;  // Can be carried (0-no, 1-yes)
        ace_dragging_carryPosition[] = {0, 1.2, 0};  // Offset of the model from the body while dragging (same as attachTo) (default: [0, 1, 1])
        ace_dragging_carryDirection = 90;  // Model direction while dragging (same as setDir after attachTo) (default: 0)
        ace_dragging_ignoreWeightCarry = 1; // Ignore weight limitation for carrying (0-no, 1-yes)

		// Cargo
		ace_cargo_size = 1;  // Cargo space the object takes
        ace_cargo_canLoad = 1;  // Enables the object to be loaded (1-yes, 0-no)
        ace_cargo_noRename = 0;  // Blocks renaming object (1-blocked, 0-allowed)
        ace_cargo_blockUnloadCarry = 0; // Blocks object from being automatically picked up by player on unload
	};

	class Sania : Sania_Base
    {
		picture = "\sania\pictures\preview_sania.jpg";
		editorPreview = "\sania\pictures\preview_sania.jpg";
		scope = 2;
		model = "sania\sania.p3d";
		displayName = "REB Sania";
		vehicleClass = "sania_podavitel";
		faction = "sania";

		class UserActions
		{
			// class DisassembleJammer
			// {
			// 	displayName="Put in inventory";
			// 	priority=0.5;
			// 	radius=7;
			// 	position=;
			// 	showWindow=0;
			// 	onlyForPlayer=1;
			// 	icon=;
			// 	condition="this call DB_fnc_jammerCanDisassembly";
			// 	statement="this call DB_fnc_addJammerToInventory";
			// };
		};
        class Attributes
        {
            PARAMETER(Radius,"100")
            PARAMETER(Deadzone,"30")
            PARAMETER(Strength,"0.5")
            PARAMETER_BOOL(IsAttachable,1)
            PARAMETER_BOOL(CanModifyRange,1)
            PARAMETER_BOOL(CanModifyStrength,0)
            PARAMETER_BOOL(IsActive,1)
            PARAMETER(linkedObjects,"")
        };
    };
	class Sania_with_tripod : Sania_Base
    {
		picture = "\sania\pictures\preview_sania_tripod.jpg";
		editorPreview = "\sania\pictures\preview_sania_tripod.jpg";
		scope = 2;
		model = "sania\tripod.p3d";
		displayName = "REB Sania with tripod";
		vehicleClass = "sania_podavitel";
		faction = "sania";
    };

	class Volnorez_1 : Sania
    {
		picture = "\sania\pictures\preview_volnorez.jpg";
		editorPreview = "\sania\pictures\preview_volnorez.jpg";
		scope = 2;
		model = "sania\volnorez.p3d";
		displayName = "REB Volnorez";
		vehicleClass = "sania_podavitel";
		faction = "sania";
    };

	class B_Bergen_dgtl_F;
	class Sania_Bag: B_Bergen_dgtl_F
	{
	    displayName="REB Sania Bag";
		scope = 2;
	    class assembleInfo
	    {
	        assembleTo="Sania";
	        base=;
	        displayName="REB Sania";
	        dissasembleTo[]={};
	        primary=1;
	    };
	};

	class Volnorez_Bag: B_Bergen_dgtl_F
	{
	    displayName="REB Volnorez Bag";
		scope = 2;
	    class assembleInfo
	    {
	        assembleTo="Volnorez_1";
	        base=;
	        displayName="REB Volnorez";
	        dissasembleTo[]={};
	        primary=1;
	    };
	};

	class Box_EAF_Equip_F;
	class Sania_Crate: Box_EAF_Equip_F
	{
		displayName="REB Sania Crate";
		scope=2;
		scopeCurator=2;
		transportMaxWeapons=3;
		transportMaxItems=1;
		transportMaxMagazines=3;
		transportMaxBackpacks=3;
		class TransportBackpacks
		{
		   class _xx_Sania_Bag
		   {
		       backpack="Sania_Bag";
		       count=1;
		   };
		};
		class TransportMagazines
		{		
		};
		class TransportItems
		{
		};
		class TransportWeapons
		{		
		};
	};

	class Volnorez_Crate: Box_EAF_Equip_F
	{
		displayName="REB Volnorez Crate";
		scope=2;
		scopeCurator=2;
		transportMaxWeapons=3;
		transportMaxItems=1;
		transportMaxMagazines=3;
		transportMaxBackpacks=3;
		class TransportBackpacks
		{
		   class _xx_Volnorez_Bag
		   {
		       backpack="Volnorez_Bag";
		       count=1;
		   };
		};
		class TransportMagazines
		{		
		};
		class TransportItems
		{
		};
		class TransportWeapons
		{		
		};
	};
};