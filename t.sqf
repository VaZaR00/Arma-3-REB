_items = [];

if !(isNil "REB_initingRebItems") exitWith {};
REB_initingRebItems = _thisScript;

if !(IS_ARR(_items)) then {
	if (STR_EMPTY(_items)) then {
		_items = keys REB_all_hashes;
	} else {
		_items = [_items];
	};
};

(allUnits + vehicles + ("GroundWeaponHolder" allObjects 0)) apply {
	_o = _x;
	// IF_(!ISNIL(_o GV "REB_var_hasActiveReb"), SKIP);
	{
		_res = false;

		[_o, _x] params["_container", ["_item", ""]];

		if (_container isEqualTo objNull) exitWith {};

		PR _allContainerItems = (((everyContainer _container) apply {_x#0}) + ((getItemCargo _container)#0)) apply {WITH_PREF(_x)};
		PR _rebsInContainer = (if (STR_EMPTY(_item)) then {(keys REB_all_hashes)} else {[_item]}) select {WITH_PREF(_x) in _allContainerItems};

		_rebsInContainer pushBack _container;

		PR _rebItem = "";
		PR _hasSet = if (count _rebsInContainer > 0) then {
			PR _rebsSorted = ([
				_rebsInContainer, 
				[], 
				{GET_HASHS_OBJ_VAL(GET_HASH(_x), "REB_var_rebMaxRange", 0, _x)}, 
				"DESCEND", 
				{HAS_ACTIVE_REB(_x) && (IS_HASH(GET_INIT_HASH(_x)))}
			] call BIS_fnc_sortBy);

			if (count _rebsSorted == 0) exitWith {false};

			_rebItem = _rebsSorted#0;

			if !(IS_HASH(GET_INIT_HASH(_rebItem))) EW {false};

			// if !((_container GV ["REB_var_currentRebItem", ""]) isEqualTo _rebItem) EW {false};
			
			[_container, _rebItem] call REB_fnc_changeRebOnObj;
			_container setVariable ["REB_var_currentRebItem", _rebItem, true];
			true
		} else {false};

		if (_hasSet) exitWith {true};

		if (_container in REB_all_rebs) then {
			// [_container] call REB_fnc_removeReb;
			[_container, objNull] call REB_fnc_setRebToObj;
		};
		_container setVariable ["REB_var_currentRebItem", nil, true];

		if (false) EX;
	} forEach _items;
};
REB_initingRebItems = nil;