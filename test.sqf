All_containers = [];

{
	(everyContainer _x) apply {All_containers pushBack (_x#1)};
} forEach (vehicles + ("GroundWeaponHolder" allObjects 0));

{
	All_containers pushBack (backpackContainer _x);
} forEach (allunits + allDead);

All_containers