#define PR private
#define MGVAR missionNamespace getVariable
#define MSVAR missionNamespace setVariable
#define LOC  
#define LOG hint str 

// #define LOC localize
#define SKIP continue
#define getDef getOrDefault
#define HASH_PREF "REB_HASH_"
#define H_PREF(s) (HASH_PREF + s)
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_OBJ(o) (o isEqualType objNull)
#define IS_ARR(o) (o isEqualType [])
#define IS_STR(s) (s isEqualType "")
#define IS_REB(r) ((r in REB_all_rebs) || {(HASH_PREF + r) in REB_all_hashes})
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define SAVE_HASH(h) missionNamespace setVariable [(h get "HASH_VAR_NAME"), h, true];
#define HASH_NAME(h) (h getDef ["HASH_VAR_NAME", ""])
#define GET_HASH(r) ([r] call REB_fnc_getObjHash)
#define R_HASH(r) r = GET_HASH(r);
#define SET_HASH_VAL(h, p, v) [h, p, v] call REB_fnc_setProperty;
#define GET_HASH_VAL(h, p, d) ([h, p, d] call REB_fnc_getProperty)
#define UPD_HASH(h) missionNamespace setVariable [(h get "HASH_VAR_NAME"), h, true];
#define REB_itemRebsClasses (keys REB_all_hashes)
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define OBJ_CURR_HASH(o) (call (o getVariable ["REB_currentRebHash", {o}]))