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

#define LOC  
// #define LOC localize
#define SKIP continue
#define EW exitWith
#define EX EW {};
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c) if (c) exitWith {}
#define IF_EXW(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define ISNIL(v) isNil STR(v)
#define NIL_(v) IF_ELSE(ISNIL(v), nil, v)
#define getDef getOrDefault
#define HASH_PREF "REB_HASH_"
#define H_PREF(s) (HASH_PREF + s)
#define WITH_PREF(s) (if (HASH_PREF in s) then {s} else {H_PREF(s)})
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_OBJ(o) (o isEqualType objNull)
#define IS_OBJNULL(o) (o isEqualTo objNull)
#define IS_OBJNULL_DEF(o) IF_ELSE(IS_OBJ(o), o, objNull)
#define IS_ARR(o) (o isEqualType [])
#define IS_STR(s) (s isEqualType "")
#define IS_REB(r) (r in REB_all_rebs)
#define IS_REB_HASH(h) (IS_HASH(h) && {HASH_NAME(h) in REB_all_hashes})
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (count a == 0)
#define UPD_HASH(h) MSVAR [(h get "HASH_VAR_NAME"), h, true];
#define UPD_VAR(v) MSVAR [STR(v) , v, true];
#define HASH_NAME(h) (h getDef ["HASH_VAR_NAME", ""])
#define GET_HASH(r) ([r] call REB_fnc_getObjHash)
#define GET_INIT_HASH(r) ([r] call REB_fnc_getHash)
#define R_HASH(r) r = GET_HASH(r);
#define SET_HASH_VAL(h, p, v) [h, p, v] call REB_fnc_setProperty;
#define GET_HASH_VAL(h, p, d) ([h, p, d] call REB_fnc_getProperty)
#define GET_HASH_OBJS(h) GET_HASH_VAL(_hash, "HASH_CURRENT_OBJS", [])
#define GET_HASHS_OBJ_VAL(h, p, d, o) ([h, p, d, o] call REB_fnc_getProperty)
#define SET_HASHS_OBJ_VAL(h, p, v, o) [h, p, v, o] call REB_fnc_setProperty;
#define GV_HAS_ACTIVE_REB(o) GET_HASHS_OBJ_VAL(GET_HASH(o), "REB_var_hasActiveReb", false, o)
#define GV_HAS_ACTIVE_REB_TRUE(o) GET_HASHS_OBJ_VAL(GET_HASH(o), "REB_var_hasActiveReb", true, o)
#define HAS_ACTIVE_REB(o) (IS_OBJNULL_DEF(o) getVariable ["REB_var_hasActiveReb", false])
#define HAS_ACTIVE_REB_TRUE(o) (IS_OBJNULL_DEF(o) getVariable ["REB_var_hasActiveReb", false])
#define REB_itemRebsClasses (keys REB_all_hashes)
#define CURR_HASH(o) (call (o getVariable ["REB_currentRebHash", {o}]))
#define OBJ_CURR_HASH(o) IF_ELSE(IS_OBJ(o), CURR_HASH(o), o)
#define OBJ_HAS_REB(o) (IS_HASH(OBJ_CURR_HASH(o)))
#define HASH_MAXRANGE(h) GET_HASH_VAL(h, "REB_var_rebMaxRange", 0)
#define HASH_MAXDEADZ(h) GET_HASH_VAL(h, "REB_var_rebMaxDeadzone", 0)
#define HASH_MAXSTREN(h) GET_HASH_VAL(h, "REB_var_rebMaxStrength", 0)
#define HASH_ISACTIVE(h) GET_HASH_VAL(h, "REB_var_rebIsOn", false)

// _thisScript spawn {
//     sleep 10;
//     terminate _this;
// };