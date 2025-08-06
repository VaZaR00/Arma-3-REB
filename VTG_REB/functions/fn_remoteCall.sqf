#include "defines.h"

params["_thisArgs", "_clientId", "_tempClientVar"];
_thisArgs params["_args", "_code"];

private _res = _args call _code;

MSVAR [_tempClientVar, _res, _clientId];