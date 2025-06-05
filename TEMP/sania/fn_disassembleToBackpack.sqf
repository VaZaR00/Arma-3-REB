params ["_jammer"];

private _jammerType = typeOf _jammer;
private _pos = getPosATL _jammer;

private _backpackClass = switch (toUpper _jammerType) do {
	case "SANIA": { "Sania_Bag" };
	case "VOLNOREZ_1": { "Volnorez_Bag" };
	default { "" };
};

if (_backpackClass isEqualTo "") exitWith {
	hint "Unknown jammer type, cannot disassemble.";
};

deleteVehicle _jammer;

private _holder = createVehicle ["GroundWeaponHolder_Scripted", _pos, [], 0, "CAN_COLLIDE"];
_holder addBackpackCargoGlobal [_backpackClass, 1];

hint format ["%1 disassembled into backpack.", _jammerType];
