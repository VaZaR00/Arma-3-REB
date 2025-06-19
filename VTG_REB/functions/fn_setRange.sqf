#include "defines.h"

params [["_reb", objNull]];

REB_currentHandledReb = _reb;
REB_currentHandledRebHash = GET_HASH(_reb);

IF_EX(!IS_REB(REB_currentHandledReb));
IF_EX(!IS_REB_HASH(REB_currentHandledRebHash));

PR _textShow = {format ["%1: %2 m", LOC "$STR_REB_VALUE", round _this]};

PR _onSliderPosChanged = {
    params ["_ctrl", "_newValue"];
	private _disp = ctrlParent _ctrl;
	_newValue = round ((REB_currentHandledRebHash getDef ["REB_var_rebMaxRange", 100]) * (_newValue/10));
	(_disp displayCtrl 11) ctrlSetText (format ["%1: %2 m", LOC "$STR_REB_VALUE", _newValue]);
};

PR _onButtonClick = {
    private _disp = ctrlParent (_this select 0);
    private _sliderVal = (sliderPosition (_disp displayCtrl 10));
	private _newRange = round ((REB_currentHandledRebHash get "REB_var_rebMaxRange") * (_sliderVal/10));
    private _newDeadzone = (_newRange / (REB_currentHandledRebHash get "REB_var_rebRatio"));

    SET_HASHS_OBJ_VAL(REB_currentHandledRebHash, "REB_var_rebRange", _newRange, REB_currentHandledReb)
    SET_HASHS_OBJ_VAL(REB_currentHandledRebHash, "REB_var_rebDeadzone", _newDeadzone, REB_currentHandledReb)

    UPD_HASH(REB_currentHandledRebHash)

	REB_currentHandledReb = nil;
	REB_currentHandledRebHash = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow] call REB_fnc_setValueDialog;
