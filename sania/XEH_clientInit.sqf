[["<t color='#0ed145'>Attach Sania Jammer</t>", { "Item_JammerSania" call DB_fnc_updateJammerPos }, [], 1.5, false, true, "", "[""Item_JammerSania""] call DB_fnc_playerActions_canPlace"]] call CBA_fnc_addPlayerAction;
[["<t color='#0ed145'>Attach Volnorez Jammer</t>", { "Item_JammerVolnorez" call DB_fnc_updateJammerPos }, [], 1.5, false, true, "", "[""Item_JammerVolnorez""] call DB_fnc_playerActions_canPlace"]] call CBA_fnc_addPlayerAction;
[["<t color='#0ed145'>Attach</t>", { call DB_fnc_createJammer;  call DB_fnc_BackpackRemove; }, [], 1.5, true, true, "", "call DB_fnc_playerActions_canAttach"]] call CBA_fnc_addPlayerAction;
[["<t color='#ec1c24'>Release</t>", { true call DB_fnc_releaseJammer }, [], 1.5, true, true, "", "call DB_fnc_playerActions_canRelease"]] call CBA_fnc_addPlayerAction;

[] spawn {
    waitUntil { !isNull findDisplay 46 };

    findDisplay 46 displayAddEventHandler ["KeyDown", {
        private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    
        if (isNull (_player getVariable ["DB_currentJammingObj", objNull])) exitWith {};

        private _lockedActions = ["binocular", "SwitchPrimary", "SwitchHandgun", "SwitchSecondary", "SwitchWeaponGrp1", "SwitchWeaponGrp2", "SwitchWeaponGrp3", "SwitchWeaponGrp4", "throw"];

        if (_lockedActions findIf { (inputAction _x) != 0 } != -1) then {
            true;
        };
    }];
};