#include "defines.h"

params [["_obj", objNull], ["_rebClass", ""], ["_rebClassMaxRange", 0]];

REB_currentHandledObj = _obj;
REB_currentHandledReb = _rebClass;
REB_currentHandledRebMaxRange = _rebClassMaxRange;

PR _textShow = {format ["%1: %2 m", LOC "$STR_REB_VALUE", round _this]};

PR _onSliderPosChanged = {
    params ["_ctrl", "_newValue"];
	private _disp = ctrlParent _ctrl;
	_newValue = round (REB_currentHandledRebMaxRange * (_newValue/10));
	(_disp displayCtrl 11) ctrlSetText (format ["%1: %2 m", LOC "$STR_REB_VALUE", _newValue]);
};

PR _onButtonClick = {
    private _disp = ctrlParent (_this select 0);
    private _sliderVal = (sliderPosition (_disp displayCtrl 10));

    _this = [REB_currentHandledObj, REB_currentHandledReb, REB_currentHandledRebMaxRange, _sliderVal];

    EXEC_ON_SERVER
        params["_obj", "_reb", "_maxRng", "_sliderVal"];

        PR _or = GET_RO_BY_HASH(_obj, _reb);
        PR _newRange = round (_maxRng * (_sliderVal/10));
        PR _newDeadzone = (_newRange / (INSTANCE_VAR(_or, "ratio")));

        METHOD(_or, "Range", _newRange);
        METHOD(_or, "Deadzone", _newDeadzone);
    EXEC_ON_SERVER_END

	REB_currentHandledObj = nil;
	REB_currentHandledReb = nil;
	REB_currentHandledRebHash = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow] call REB_fnc_setValueDialog;
