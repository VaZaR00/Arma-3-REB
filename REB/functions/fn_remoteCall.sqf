#include "defines.h"

params[["_thisArgs", [], [[]]], ["_code", {}, [{}]]];
_thisArgs params[["_args", []], ["_clientId", false, [0, false]], ["_tempClientVar", "", [""]]];

["REMOTE_CALL", _this] MP_RLOG;

private _res = _args call _code;

if ((_clientId isEqualTo false) || (_tempClientVar isEqualTo "")) EX;

["RSULT_REMOTE_CALL", _res] MP_RLOG;

MSVAR [_tempClientVar, _res, _clientId];