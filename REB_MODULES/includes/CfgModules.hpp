#define STR_PREF STR_WMT_Module_Device_
#define SSTR_N(s) $##STR_PREF##s
#define SSTR_DESC_N(s) $##STR_PREF##DESC_##s
#define SSTR(s) STR(SSTR_N(s))
#define SSTR_DESC(s) STR(SSTR_DESC_N(s))

class CfgFactionClasses
{
	class REB
	{
		displayName="REB";
		priority=0;
		side=7;
	};
};
class ArgumentsBaseUnits;
class CfgVehicles
{
    class Logic;
    class Module_F: Logic
    {
        class ModuleDescription
        {
            class AnyBrain;
        };
    };
    class PREF(Device): Module_F
    {
        scope = 2;
        author = "Vazar";
        displayName = "REB Device";
        category = "REB";
        function = SFUNC(initModuleRebDevice);
        icon = "\a3\Modules_F_Curator\Data\portraitRadioChannelCreate_ca.paa";
        portrait = "\a3\Modules_F_Curator\Data\portraitRadioChannelCreate_ca.paa";
        functionPriority = 2;
        isGlobal = 1;
        isTriggerActivated = 0;

        class Arguments: ArgumentsBaseUnits
        {
            class Object
            {
                displayName = SSTR(Object);
                description = SSTR_DESC(Object);
                typeName = "STRING";
                defaultValue = "";
            };
            class Radius
            {
                displayName = SSTR(Radius);
                description = SSTR_DESC(Radius);
                typeName = "NUMBER";
                defaultValue = 100;
            };
            class Deadzone
            {
                displayName = SSTR(Deadzone);
                description = SSTR_DESC(Deadzone);
                typeName = "NUMBER";
                defaultValue = 30;
            };
            class Strength
            {
                displayName = SSTR(Strength);
                description = SSTR_DESC(Strength);
                typeName = "NUMBER";
                defaultValue = 0.5;
            };
            class IsAttachable
            {
                displayName = SSTR(IsAttachable);
                description = SSTR_DESC(IsAttachable);
                typeName = "NUMBER";
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0; default = 1;};
                };
            };
            class CanModifyRange
            {
                displayName = SSTR(CanModifyRange);
                description = SSTR_DESC(CanModifyRange);
                typeName = "NUMBER";
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1; default = 0;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
            class CanModifyStrength
            {
                displayName = SSTR(CanModifyStrength);
                description = SSTR_DESC(CanModifyStrength);
                typeName = "NUMBER";
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1;};
                    class No   {name = SSTR(No); value = 0; default = 1;};
                };
            };
            class IsActive
            {
                displayName = SSTR(IsActive);
                description = SSTR_DESC(IsActive);
                typeName = "NUMBER";
                class values
                {
                    class Yes    {name = SSTR(Yes); value = 1; default = 0;};
                    class No   {name = SSTR(No); value = 0;};
                };
            };
        };
    };
    // Change priority to default module for create diary
    class ModuleCreateDiaryRecord_F : Module_F
    {
        functionPriority = 5;
    };
};
