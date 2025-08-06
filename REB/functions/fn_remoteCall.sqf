#include "defines.h"

params[["_thisArgs", [], [[]]], ["_code", {}, [{}]]];
_thisArgs params[["_args", []], ["_clientId", -1, [0]], ["_tempClientVar", "", [""]]];

private _res = _args call _code;

if ((_clientId isEqualTo -1) || (_tempClientVar isEqualTo "")) EX;

MSVAR [_tempClientVar, _res, _clientId];