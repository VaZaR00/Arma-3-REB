#define PR private
#define GV getVariable
#define SV getVariable
#define MN missionNamespace
#define MGVAR MN GV
#define MSVAR MN SV
#define LOC  
#define LOG hint str 

// #define LOC localize
#define SKIP continue
#define getDef getOrDefault
#define HASH_PREF "REB_HASH_"
#define H_PREF(s) (HASH_PREF + s)
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_OBJ(o) (o isEqualType objNull)
#define IS_OBJNULL(o) (o isEqualTo objNull)
#define IS_ARR(o) (o isEqualType [])
#define IS_STR(s) (s isEqualType "")
#define IS_REB(r) ((r in REB_all_rebs) || {(HASH_PREF + r) in REB_all_hashes})
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (count a == 0)
#define UPD_HASH(h) MSVAR [(h get "HASH_VAR_NAME"), h, true];
#define UPD_VAR(v) MSVAR [#v , v, true];
#define HASH_NAME(h) (h getDef ["HASH_VAR_NAME", ""])
#define GET_HASH(r) ([r] call REB_fnc_getObjHash)
#define GET_INIT_HASH(r) ([r] call REB_fnc_getHash)
#define R_HASH(r) r = GET_HASH(r);
#define SET_HASH_VAL(h, p, v) [h, p, v] call REB_fnc_setProperty;
#define GET_HASH_VAL(h, p, d) ([h, p, d] call REB_fnc_getProperty)
#define GET_HASH_OBJS(h) GET_HASH_VAL(_hash, "HASH_CURRENT_OBJS", [])
#define GET_HASHS_OBJ_VAL(h, p, d, o) ([h, p, d, o] call REB_fnc_getProperty)
#define SET_HASHS_OBJ_VAL(h, p, v, o) [h, p, v, o] call REB_fnc_setProperty;
#define REB_itemRebsClasses (keys REB_all_hashes)
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define CURR_HASH(o) ([o] call (o getVariable ["REB_currentRebHash", {_this}]))
#define OBJ_CURR_HASH(o) IF_ELSE(IS_OBJ(o), CURR_HASH(o), o)
#define OBJ_HAS_REB(o) (IS_HASH(OBJ_CURR_HASH(o)))