params ["_jammer", "_newRange"]; // Accepts both the jammer and the desired range

// Update the jammer range
_jammer setVariable ["DB_Jammer_range", _newRange, true]; // Broadcast to all clients



hintSilent format ["The jammer range is now %1 meters", _newRange];
