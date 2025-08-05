#include "defines.h"

params [["_onBtnClick", {}], ["_onSliderPosChanged", {}], ["_showText", {}], ["_sliderStartPos", 0]];


private _display = findDisplay 46 createDisplay "RscDisplayEmpty";

private _slider = _display ctrlCreate ["RscXSliderH", 10];
_slider ctrlSetPosition [
    0.4 * safezoneW + safezoneX,
    0.4 * safezoneH + safezoneY,
    0.2 * safezoneW,
    0.03 * safezoneH
];
_slider ctrlAddEventHandler ["SliderPosChanged", _onSliderPosChanged];
_slider sliderSetPosition _sliderStartPos;
_slider ctrlCommit 0;


private _text = _display ctrlCreate ["RscText", 11];
_text ctrlSetPosition [
    0.4 * safezoneW + safezoneX,
    0.435 * safezoneH + safezoneY,
    0.1 * safezoneW,
    0.03 * safezoneH
];
_text ctrlSetText ((sliderPosition _slider) call _showText);
_text ctrlCommit 0;


private _button = _display ctrlCreate ["RscButton", 12];
_button ctrlSetText "OK";
_button ctrlSetPosition [
    0.45 * safezoneW + safezoneX,
    0.48 * safezoneH + safezoneY,
    0.1 * safezoneW,
    0.04 * safezoneH
];
_button ctrlCommit 0;
_button ctrlAddEventHandler ["ButtonClick", _onBtnClick];

[_slider, _sliderStartPos] call _onSliderPosChanged;