private _player = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
private _jammer = _player getVariable ["DB_currentJammingObj", objNull];

if (isNull _jammer) exitWith {};

private _intersections = _jammer getVariable ["DB_jammer_intersections", []];

private _jammerType = typeOf _jammer;
private _position = _intersections # 0 # 0;
private _intersectObject = _intersections # 0 # 2;
private _intersectObjectType = "";
private _vectorDirAndUp = [vectorDir _jammer, vectorUp _jammer];

if (!isNil "_intersectObject") then {
	_intersectObjectType = (_intersectObject call BIS_fnc_objectType) # 0;
};

if ((_intersections isEqualTo []) or (_intersectObjectType == "Soldier")) exitWith {
	hintSilent "Cannot place";
};

if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
	_vectorDirAndUp = [_jammer, _intersectObject] call BIS_fnc_vectorDirAndUpRelative;
};

false call DB_fnc_releaseJammer;

_jammer = _jammerType createVehicle [0, 0, 0];

if (_intersectObjectType in ["Vehicle", "VehicleAutonomous", "Object"]) then {
	_jammer attachTo [_intersectObject, _intersectObject worldToModel (ASLToAGL _position)];

	_intersectObject setVariable ["DB_object_attachedJammer", _jammer, true];
	_intersectObject addEventHandler ["Killed", {
		params ["_object"];

		deleteVehicle (_object getVariable ["DB_object_attachedJammer", objNull]);

		_object setVariable ["DB_object_attachedJammer", nil, true];
		_object removeEventHandler ["Killed", _thisEventHandler];
	}];
};

// if cannot attach
if !(_jammer in attachedObjects _intersectObject) then {
	[_jammer, false] remoteExec ["enableSimulationGlobal", 2];
	_jammer setPosASL _position;
};

_jammer setVariable ["DB_jammer_isActive", true, true];
_jammer setVectorDirAndUp _vectorDirAndUp;