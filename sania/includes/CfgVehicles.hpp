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
			class REB_Enabled
			{
				displayName = "$STR_REB_Enabled";
				tooltip = "$STR_REB_Enabled";
				property = "REB_Enabled";
				control = "CheckboxNumber";
				expression = "_this setVariable ['REB_var_hasActiveReb', (_value isEqualTo 1) , true];";
				defaultValue = "1";
				validate = "number"; 
			};
			class REB_Range
			{
				displayName = "$STR_REB_Range";
				tooltip = "$STR_REB_Range";
				property = "REB_Range";
				control = "EditShort";
				expression = "[_this, 'REB_var_rebMaxRange', _value] call DB_fnc_setRebValAtt";
				defaultValue = "'100'";
				typeName = "STRING";
				validate = "none";
			};
			class REB_Deadzone
			{
				displayName = "$STR_REB_Deadzone";
				tooltip = "$STR_REB_Deadzone";
				property = "REB_Deadzone";
				control = "EditShort";
				expression = "[_this, 'REB_var_rebMaxDeadzone', _value] call DB_fnc_setRebValAtt";
				defaultValue = "'30'";
				typeName = "STRING";
				validate = "none";
			};
			class REB_Strength
			{
				displayName = "$STR_REB_Strength";
				tooltip = "$STR_REB_Strength";
				property = "REB_Strength";
				control = "EditShort";
				expression = "[_this, 'REB_var_rebMaxStrength', _value] call DB_fnc_setRebValAtt";
				defaultValue = "'0.8'";
				typeName = "STRING";
				validate = "none";
			};
			class REB_canChangeRange
			{
				displayName = "$REB_canChangeRange";
				tooltip = "$REB_canChangeRange";
				property = "REB_canChangeRange";
				control = "CheckboxNumber";
				expression = "_this setVariable ['REB_var_canChangeRange', (_value isEqualTo 1) , true];";
				defaultValue = "1";
				validate = "number";
			};
			class REB_canChangeStrength
			{
				displayName = "$REB_canChangeStrength";
				tooltip = "$REB_canChangeStrength";
				property = "REB_canChangeStrength";
				control = "CheckboxNumber";
				expression = "_this setVariable ['REB_var_canChangeStrength', (_value isEqualTo 1) , true];";
				defaultValue = "1";
				validate = "number";
			};
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
			class DisassembleJammer
			{
				displayName="Put in inventory";
				priority=0.5;
				radius=7;
				position=;
				showWindow=0;
				onlyForPlayer=1;
				icon=;
				condition="this call DB_fnc_jammerCanDisassembly";
				statement="this call DB_fnc_addJammerToInventory";
			};
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