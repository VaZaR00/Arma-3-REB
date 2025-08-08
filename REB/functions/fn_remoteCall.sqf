#include "defines.h"

params[["_thisArgs", [], [[]]], ["_code", {}, [{}]]];
_thisArgs params[["_args", []], ["_clientId", false, [0, false]], ["_tempClientVar", "", [""]]];

private _res = _args call _code;

if ((_clientId isEqualTo false) || (_tempClientVar isEqualTo "")) EX;

MSVAR [_tempClientVar, _res, _clientId];