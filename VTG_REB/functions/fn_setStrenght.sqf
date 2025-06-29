#include "defines.h"

params [["_obj", objNull], ["_rebClass", ""], ["_rebClassMaxStrength", 0]];

REB_currentHandledObj = _obj;
REB_currentHandledReb = _rebClass;
REB_currentHandledRebMaxStrength = _rebClassMaxStrength;

PR _textShow = {format ["%1: %2", LOC "$STR_REB_VALUE", _this]};

PR _onSliderPosChanged = {
    params ["_ctrl", "_newValue"];
	private _disp = ctrlParent _ctrl;
	_newValue = (REB_currentHandledRebMaxStrength * (_newValue/10)) toFixed 2;
	(_disp displayCtrl 11) ctrlSetText (format ["%1: %2", LOC "$STR_REB_VALUE", _newValue]);
};

PR _onButtonClick = {
    private _disp = ctrlParent (_this select 0);
    private _sliderVal = (sliderPosition (_disp displayCtrl 10));

    _this = [REB_currentHandledObj, REB_currentHandledReb, REB_currentHandledRebMaxStrength, _sliderVal];

    EXEC_ON_SERVER
        params["_obj", "_reb", "_maxStr", "_sliderVal"];

        PR _or = GET_RO_BY_HASH(_obj, _reb);
        PR _newRange = round (_maxStr * (_sliderVal/10));

        METHOD(_or, "Strenght", _newRange);
    EXEC_ON_SERVER_END
	
	REB_currentHandledObj = nil;
	REB_currentHandledReb = nil;
	REB_currentHandledRebMaxStrength = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow] call REB_fnc_setValueDialog;