#include "defines.h"

params [["_reb", objNull]];

REB_currentHandledReb = GET_HASH(_reb);

private _display = findDisplay 46 createDisplay "RscDisplayEmpty";

private _slider = _display ctrlCreate ["RscXSliderH", 10];
_slider ctrlSetPosition [
    0.4 * safezoneW + safezoneX,
    0.4 * safezoneH + safezoneY,
    0.2 * safezoneW,
    0.03 * safezoneH
];
_slider ctrlCommit 0;

private _text = _display ctrlCreate ["RscText", 11];
_text ctrlSetPosition [
    0.4 * safezoneW + safezoneX,
    0.435 * safezoneH + safezoneY,
    0.1 * safezoneW,
    0.03 * safezoneH
];
_text ctrlSetText format ["%1: %2", LOC "$STR_REB_VALUE", (sliderPosition _slider)];
_text ctrlCommit 0;

_slider ctrlAddEventHandler ["SliderPosChanged", {
    params ["_ctrl", "_newValue"];
	private _disp = ctrlParent _ctrl;
	_newValue = ((REB_currentHandledReb getDef ["REB_var_rebMaxStrength", 100]) * (_newValue/10)) toFixed 2;
	(_disp displayCtrl 11) ctrlSetText (format ["%1: %2", LOC "$STR_REB_VALUE", _newValue]);
}];

private _button = _display ctrlCreate ["RscButton", 12];
_button ctrlSetText "OK";
_button ctrlSetPosition [
    0.45 * safezoneW + safezoneX,
    0.48 * safezoneH + safezoneY,
    0.1 * safezoneW,
    0.04 * safezoneH
];
_button ctrlCommit 0;
_button ctrlAddEventHandler ["ButtonClick", {
    private _disp = ctrlParent (_this select 0);
    private _sliderVal = (sliderPosition (_disp displayCtrl 10));
	private _newStrenght = ((REB_currentHandledReb getDef ["REB_var_rebMaxStrength", 0.5]) * (_sliderVal/10));

	REB_currentHandledReb set ["REB_var_rebStrength", _newStrenght];

    UPD_HASH(REB_currentHandledReb)
	
	// private _rebItem = _unit getVariable ["REB_var_currentRebItem", ""];

	// if !(_rebItem isEqualTo "") then {
	// 	(REB_itemRebsClasses get _rebItem) setVariable ["REB_var_rebStrength", _newStrenght, true];
	// };

	REB_currentHandledReb = nil;

    _disp closeDisplay 0;
}];
