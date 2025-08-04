// Очистка переменных
player setVariable ["REB_currentAttachObj", nil];
player setVariable ["REB_currentAttachObjType", nil];
player setVariable ["REB_currentAttachItem", nil];
player setVariable ["REB_attachmentTempObj", nil];

player action ["WeaponInHand", player];
player forceWalk false;

// Удаление действий
[player, (missionNamespace getVariable ["REB_TEMP_placement_attachAction", -1])] call BIS_fnc_holdActionRemove;
player removeAction (missionNamespace getVariable ["REB_TEMP_placement_releaseAction", -1]);