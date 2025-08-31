#include "defines.h"

FILE_ONLY_SPAWN


params [["_obj", objNull], ["_ref", ""], ["_itemRef", 0]];

private _objReb = _obj;
if !(IS_OOP(_objReb)) then {
    _objReb = _this call REB_fnc_getObjectRebByRef; 
};

if (!IS_OOP(_objReb)) exitWith {};

REB_currentHandledReb = _objReb;
_obj = INSTANCE_VAR(_objReb, "Object");

REB_currentHandledRebClass = INSTANCE_VAR(_objReb, "Reb_class");
REB_currentHandledRebMaxStrength = INSTANCE_VAR(_objReb, "Max_Strenght");
private _strenght = INSTANCE_VAR(_objReb, "Strenght");


private _startPos = if (_strenght == 0) then {0} else {_strenght * (10 / REB_currentHandledRebMaxStrength)};

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

    _this = [REB_currentHandledReb, REB_currentHandledRebClass, REB_currentHandledRebMaxStrength, _sliderVal];

    // EXEC_ON_SERVER_START
        params["_reb", "_rebclass", "_maxStr", "_sliderVal"];

        PR _newStrenght = (_maxStr * (_sliderVal/10));

        METHOD(_reb, "Set_Strenght", _newStrenght);
    // EXEC_ON_SERVER_END
	
	REB_currentHandledReb = nil;
	REB_currentHandledRebClass = nil;
	REB_currentHandledRebMaxStrength = nil;

    _disp closeDisplay 0;
};

[_onButtonClick, _onSliderPosChanged, _textShow, _startPos] call REB_fnc_setValueDialog;