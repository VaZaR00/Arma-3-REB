#include "defines.h"

FILE_ONLY_SPAWN

params [["_obj", objNull], ["_ref", ""], ["_itemRef", 0]];

private _objReb = _obj;
if !(IS_OOP(_objReb)) then {
    _objReb = _this call REB_fnc_getObjectRebByRef;
};

if (!IS_OOP(_objReb)) exitWith {};

REB_currentHandledReb = _objReb;

REB_currentHandledRebClass = OBJ_VAR ["Reb_class", ""];
REB_currentHandledRebMaxRange = OBJ_VAR ["Max_Range", 100];
private _range = OBJ_VAR ["Range", 100];

private _startPos = if (_range == 0) then {0} else {_range * (10 / REB_currentHandledRebMaxRange)};

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

    _this = [REB_currentHandledReb, REB_currentHandledRebClass, REB_currentHandledRebMaxRange, _sliderVal];

    // EXEC_ON_SERVER_START
        params["_reb", "_rebclass", "_maxRng", "_sliderVal"];

        PR _newRange = round (_maxRng * (_sliderVal/10));

        METHOD(_reb, "Set_Range", _newRange);
    // EXEC_ON_SERVER_END

	REB_currentHandledObj = nil;
	REB_currentHandledRebClass = nil;
	REB_currentHandledRebMaxRange = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow, _startPos] call REB_fnc_setValueDialog;
