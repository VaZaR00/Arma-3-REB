/*
	Name: VTG_TFAR_fnc_radioDistance

	Author: Vazar
		Встановлює коефіцієнт дальності зв'язку на рації.

	Arguments:
		0: isActive - чи активувати скрипт (за замовчуванням true)

	Return Value:
		["VTG_RadioDistanceEH", "OnTangent"] -> TFAR EventHandler Data

	Example:
		Визов в ініті:
			[] call compile preprocessFileLineNumbers "scripts\fn_radioDistance.sqf";
			Щоб відключити скрипт:
			[false] call VTG_TFAR_fnc_radioDistance;

	Additional:
		tfar_radioDistanceCoeffTable - хеш таблиця співставлення класу рації до значення коефіцієнта (за замовчуванням 1)
		Приклад:
		[
			["Класс1", 0.5],
			["Класс2", 0.2]
		]
		Якщо встановлюєте значення перед запуском скрипта то межете записати класси в такий список як вище.
		Якщо встановлюєте значення після запуска скрипта то щоб встановити значення треба записати так:
			tfar_radioDistanceCoeffTable set ["TFAR_anprc152", 0.5];

		Якщо треба скинути значення в таблиці то:
			tfar_radioDistanceCoeffTable = createHashtable
*/

#define MGVAR missionNamespace getVariable 



VTG_TFAR_fnc_radioDistance = {

params[["_isActive", true]];

["VTG_RadioDistanceEH", "OnBeforeTangent"] call TFAR_fnc_removeEventHandler;

if !(_isActive) exitWith {};


if (isNil "tfar_SW_RadioDistanceCoef") then {
	tfar_SW_RadioDistanceCoef = 1;
};
if (isNil "tfar_LR_RadioDistanceCoef") then {
	tfar_LR_RadioDistanceCoef = 1;
};
if (isNil "tfar_radioDistanceCoeffTable") then {
	tfar_radioDistanceCoeffTable = createHashmap;
};
if (tfar_radioDistanceCoeffTable isEqualType []) then {
	tfar_radioDistanceCoeffTable = createHashmapFromArray tfar_radioDistanceCoeffTable;
};

["VTG_RadioDistanceEH", "OnBeforeTangent", {
	params["_unit", "_radioClass", "_type", "_isAdditional", "_buttonDown"];

	if (_buttonDown) then {
		private _table = MGVAR ["tfar_radioDistanceCoeffTable", createHashMap];

		if !(_table isEqualType createHashMap) then {
			if (_table isEqualType []) then {
				tfar_radioDistanceCoeffTable = createHashmapFromArray _table;
			} else {
				tfar_radioDistanceCoeffTable = createHashMap;
			};
		};

		if (_radioClass isEqualType []) then {
			_transmitType = _radioClass#1;
			_radioClass = typeOf (_radioClass#0);
			if (_transmitType != "radio_settings") then {
				_radioClass = _transmitType;
				_vehCustomLRtype = (vehicle _unit) getVariable ["TF_RadioType", ""];
				if !(_vehCustomLRtype isEqualTo "") then {
					_radioClass = _vehCustomLRtype;
				};
			};
		};

		if (_type isEqualTo 0) then {
			private _splitted = (_radioClass splitString "_");
			if (parseNumber (_splitted#-1) isEqualType 0) then {
				_splitted deleteAt (count _splitted - 1);
				_radioClass = _splitted joinString "_";
			};
		};

		private _defaultCoef = switch (_type) do {
			case 0: {tfar_SW_RadioDistanceCoef};
			case 1: {tfar_LR_RadioDistanceCoef};
			default {1};
		};
		private _coef = (MGVAR ["tfar_radioDistanceCoeffTable", createHashMap]) getOrDefault [_radioClass, _defaultCoef];

		player setVariable ["tf_sendingDistanceMultiplicator", _coef];
		player setVariable ["tf_receivingDistanceMultiplicator", _coef];
		hint str ["coef", (player GetVariable "tf_sendingDistanceMultiplicator"), (player GetVariable "tf_sendingDistanceMultiplicator")];
	} else {
		[] spawn {
			player setVariable ["tf_sendingDistanceMultiplicator", 1];
			player setVariable ["tf_receivingDistanceMultiplicator", 1];
			hint str ["norm", (player GetVariable "tf_sendingDistanceMultiplicator"), (player GetVariable "tf_sendingDistanceMultiplicator")];
		};
	};

}, player] call TFAR_fnc_addEventHandler;

VTG_RadioDistanceEH = ["VTG_RadioDistanceEH", "OnBeforeTangent"];

VTG_RadioDistanceEH
};

call VTG_TFAR_fnc_radioDistance;