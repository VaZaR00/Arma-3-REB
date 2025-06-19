#include "defines.h"

params [["_reb", objNull]];

REB_currentHandledReb = _reb;
REB_currentHandledRebHash = GET_HASH(_reb);

IF_EX(!IS_REB(REB_currentHandledReb));
IF_EX(!IS_REB_HASH(REB_currentHandledRebHash));

PR _textShow = {format ["%1: %2", LOC "$STR_REB_VALUE", _this]};

PR _onSliderPosChanged = {
    params ["_ctrl", "_newValue"];
	private _disp = ctrlParent _ctrl;
	_newValue = ((REB_currentHandledRebHash getDef ["REB_var_rebMaxStrength", 100]) * (_newValue/10)) toFixed 2;
	(_disp displayCtrl 11) ctrlSetText (format ["%1: %2", LOC "$STR_REB_VALUE", _newValue]);
};

PR _onButtonClick = {
    private _disp = ctrlParent (_this select 0);
    private _sliderVal = (sliderPosition (_disp displayCtrl 10));
	private _newStrenght = ((REB_currentHandledRebHash getDef ["REB_var_rebMaxStrength", 0.5]) * (_sliderVal/10));

    SET_HASHS_OBJ_VAL(REB_currentHandledRebHash, "REB_var_rebStrength", _newStrenght, REB_currentHandledReb)

    UPD_HASH(REB_currentHandledRebHash)
	
	REB_currentHandledRebHash = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow] call REB_fnc_setValueDialog;