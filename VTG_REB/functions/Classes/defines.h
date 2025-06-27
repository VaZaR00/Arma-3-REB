#include "oop.h"

#define REB_CLS_PREF "REB_CLASS_"
#define REB_OBJ_PREF "REB_OBJECT_CLASS_"

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
#define C , 
#define EQTYPE isEqualType
#define EQTO isEqualTo
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c) if (c) exitWith {}
#define IF_EXW(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define IF_NIL_EX(v) if (isNil #v) EX;
#define ISNIL(v) isNil STR(v)
#define NIL_(v) IF_ELSE(ISNIL(v), nil, v)
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
#define IS_OOP(s) (IS_CODE(s) && {IS_STR(OBJECT_VAR(s, classname))})
#define IS_REB(r) ([r] call REB_fnc_isReb)
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (count a == 0)
#define REB_itemRebsClasses (keys REB_all_classes)
#define OBJ_REBS_LIST(o) (o GV ["REB_objectRebs", []])

// FOR OOP

#define BOOL(i) (IF_ELSE(IS_INT(i), i == 1, nil))
#define BOOL_TO_INT(b) (if (b) then {1} else {0})
#define SET_BOOL(b) (if (IS_BOOL(b)) then {b} else {0})

#define METHOD(object, method, args) ([STR(method), args] call object)
#define SELF_VAR(var) MEMBER(STR(var), nil)
#define OBJECT_VAR(object, var) METHOD(object, var, nil)
#define GET_CLASS(instance) OBJECT_VAR(instance, classname)
#define IS_INSTANCE_OF(instance, class) (OBJECT_VAR(instance, classname) EQTO class)

#define SET_GLOBALY(v) _globaly = v;
#define GLOBALY SET_GLOBALY(true)
#define LOCALY SET_GLOBALY(false)

// #define SET_CURRENT_CLASS(c) IF_(ISNIL(_mainClass), _mainClass = _class); _prevclass = _class;_class = c; 
// #define SET_MAIN_CLASS _class = _mainClass; 
// #define SELF_METHOD(var) MEMBER(STR(var), nil)
// #define CLASS_MEMBER(class, memberStr,args) CALLCLASS(_class,memberStr,args,2)
// #define CLASS_SPAWN_MEMBER(class, memberStr,args) SPAWNCLASS(_class,memberStr,args,2)
