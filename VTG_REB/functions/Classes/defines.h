#include "oop.h"

#define REB_CLS_PREF "REB_CLASS_"
#define REB_VAR_PREF "REB_VAR_"
#define REB_OBJ_PREF "REB_OBJECT_CLASS_"
#define RC_PREF(s) (REB_CLS_PREF + s)

#define STR(s) #s
#define PR private
#define GV getVariable
#define SV setVariable
#define MN missionNamespace
#define MGVAR MN GV
#define MSVAR MN SV
#define LOG hint str 
#define RLOG call {hint str _this; diag_log str _this};
#define IFLOG call {if (MGVAR ["TEMP_DO_LOG", false]) then {hint str _this; diag_log str _this}};
#define DOLOG MSVAR ["TEMP_DO_LOG", true];
#define NOLOG MSVAR ["TEMP_DO_LOG", false];

#define GET_PLAYER_DRONE (vehicle (remoteControlled player))

#define LOC  
// #define LOC localize
#define SKIP continue
#define EW exitWith
#define EX EW {};
#define C , 
#define EQTYPE isEqualType
#define EQTO isEqualTo
#define ISNIL(v) isNil STR(v)
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c) if (c) exitWith {}
#define IF_EXW(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define IF_NIL_EX(v) if (ISNIL(v)) EX;
#define IF_NIL(v, d) IF_ELSE(ISNIL(v), d, v)
#define NIL_(v) IF_NIL(v, nil)
#define SET_IF_NIL(v, d) IF_ELSE(ISNIL(v), v = d, v)
#define getDef getOrDefault
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_OBJ(o) (o isEqualType objNull)
#define IS_OBJNULL(o) (o isEqualTo objNull)
#define IS_OBJNULL_DEF(o) IF_ELSE(IS_OBJ(o), o, objNull)
#define IS_ARR(o) (o isEqualType [])
#define IS_STR(s) (s isEqualType "")
#define IS_BOOL(s) (s isEqualType true)
#define IS_CODE(s) (s isEqualType {})
#define IS_INT(s) (s isEqualType 0)
#define IS_REB(r) (r call REB_fnc_isReb)
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (count a == 0)
#define REB_itemRebsClasses (keys REB_all_classes)

#define HASHVAL_(v) CLEAR_SYMBOLS(hashValue v)

#define EXEC_ON_SERVER [_this, {
#define EXEC_ON_SERVER_END }] remoteExec ["call", 2];

#define CLEAR_SYMBOLS(s) ((s) call {PR _s = toArray _this; PR _n = count _s; PR _r = []; PR _f = true; for "_i" from 0 to (_n - 1) do {PR _c = _s select _i; if (((_c >= 48) && (_c <= 57)) || ((_c >= 65) && (_c <= 90)) || ((_c >= 97) && (_c <= 122))) then {if (_f && (_c >= 48) && (_c <= 57)) then {} else {_r pushBack _c}; _f = false;}}; toString _r})

// FOR OOP

#define BOOL(i) (IF_ELSE(IS_INT(i), i == 1, nil))
#define BOOL_TO_INT(b) (if (b) then {1} else {0})
#define SET_BOOL(b) (if (IS_BOOL(b)) then {b} else {0})
#define IS_OOP(s) (IS_CODE(s) && {IS_STR(METHOD(s, "classname", nil))})

// #define METHOD_LOCAL(object, method, args) ([method, args] call object)
// #define METHOD_GLOBAL(object, method, args) ([[method, args], object] remoteExec ["call", 0])
#define METHOD(object, method, args) ([method, args] call object)
// #define METHOD(object, method, args) (IF_ELSE(IS_GLOBALY, METHOD_GLOBAL(object, method, args), METHOD_LOCAL(object, method, args)))
#define SELF_VAR(var) MEMBER(var, nil)
#define INSTANCE_VAR(object, var) METHOD(object, var, nil)
#define GET_CLASS(instance) INSTANCE_VAR(instance, "classname")
#define IS_INSTANCE_OF(instance, class) (INSTANCE_VAR(instance, "classname") EQTO class)

#define GLOBALY_DEFAULT false

#define SET_GLOBALY(v) _globaly = v;
#define GLOBALY SET_GLOBALY(true)
#define LOCALY SET_GLOBALY(false)
#define IS_GLOBALY IF_NIL(_globaly, false)
#define EXEC_GLOBAL(code) _tempGlobaly = _globaly; SET_GLOBALY(true); code LOCALY; SET_GLOBALY(_tempGlobaly);
#define EXEC_LOCAL(code) _tempGlobaly = _globaly; SET_GLOBALY(false); code LOCALY; SET_GLOBALY(_tempGlobaly);

// for OO_OBJECT_REB_DB

#define ROVAR "REB_objectRebs"
#define ROVAR_S "REB_objectRebs_SERVER"
#define ROVAR_NAME(n) (REB_VAR_PREF + _hshVal + n)

#define SAVE_OBJ_REBS_LIST _obj SV [ROVAR, _objRebs, true];
#define SAVE_OBJ_REBS_LIST_SERVER _obj SV [ROVAR_S, _objRebs_SERVER];

#define OBJ_REBS_LIST_SERVER(o) (o GV [ROVAR_S, createHashMap])
#define OBJ_REBS_LIST_VAR_SERVER PR _objRebs_SERVER = OBJ_REBS_LIST_SERVER(_obj);
#define OBJ_REBS_LIST(o) (o GV [ROVAR, createHashMap])
#define OBJ_REBS_LIST_VAR PR _objRebs = OBJ_REBS_LIST(_obj);

#define GET_RO_BY_HASH(o, h) (OBJ_REBS_LIST(o) get h)

#define GET_REB_INSTANCE(n) (METHOD(IOO_REB_DB, "Get_reb_class", n))

// TEMP

#define HAS_ACTIVE_REB(x) false