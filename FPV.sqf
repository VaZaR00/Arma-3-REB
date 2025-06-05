// Список дронов, которым нужно отключать TI
private _fpvDrones = ["B_Crocus_AT", "B_Crocus_AP", "O_Crocus_AP", "O_Crocus_AT", "B_FPV_UA_AT"];

// Функция, которая отключает тепловизор каждые 5 сек
private _disableTIFunc = {
    params ["_drone"];
    _drone spawn {
        while {alive _this} do {
            _this disableTIEquipment true;
            sleep 5;
        };
    };
};

// Отключаем TI всем дронам, уже на карте
{
    if (typeOf _x in _fpvDrones) then {
        [_x] call _disableTIFunc;
    };
} forEach vehicles;

