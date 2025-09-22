#include "generic.h"
#include "oop.h"
#include "main.h"

#define ISLANCET ("lancet_tripod_launcher" in (typeOf vehicle player))
#define ISLANCETHANDL (ISLANCET && dialog)


/*
    MAIN REB MACRO DEFINES
*/
#define PREF_ PREFX##_
#define PREF_FNC PREFX##_fnc_
#define FUNC(f) PREF_FNC##f
#define QFUNC(f) (MGVAR [STR(PREF_FNC) + f, {}])
#define PREF_CLAS "REB_class_"
#define PREF_VAR "REB_var_"
#define PREF_OBJ_CLAS "REB_OBJECT_CLASS_"
#define PREF_QVAR(s) (PREF_VAR + s)
#define RC_PREF(s) (PREF_CLAS + s)


#define OBJ_VARPREF(v) (format["%1%2_%3", PREF_VAR, _hashVal, v])
#define OBJ_VAR _obj GV
#define OR_HASH(o) PR _hashVal = OBJ_VAR ["InstanceHash", ""];
#define OR_VARPREF(v) (format["%1%2_%3", PREF_VAR, _obj GV [OBJ_VARPREF("InstanceHash"), ""], v])


#define GET_CURR_ITEMS(p) (p GV ["REB_var_currentRebItems", CRTHSH])
#define GET_CURR_ITEMS_VAR(p) PR _currRebItems = GET_CURR_ITEMS(p);
#define SAVE_CURR_ITEMS_VAR(p) (p SV ["REB_var_currentRebItems", _currRebItems, true])
#define ADD_TO_CURR_ITEMS(i) _currRebItems set [i, nil];
#define REMOVE_FROM_CURR_ITEMS(i) _currRebItems deleteAt i;

// for OO_OBJECT_REB_DB

#define OBJ_REB(o) (MGVAR [o, {}])
#define OBJ_REB_VAR(o) (INSTANCE_VAR(o, "InstanceName"))

#define ROVAR PREF_QVAR("objectRebs")
#define ROVAR_NAME(n) (PREF_VAR + _hashVal + n)

#define SAVE_OBJ_REBS_LIST _obj SV [ROVAR, _objRebs, true];
#define SAVE_OBJ_REBS_LIST_SERVER _obj SV [ROVAR_S, _objRebs_SERVER];

#define OBJ_REBS_LIST_SERVER(o) (o GV [ROVAR_S, createHashMap])
#define OBJ_REBS_LIST_VAR_SERVER_P(o) PR _objRebs_SERVER = OBJ_REBS_LIST_SERVER(o);
#define OBJ_REBS_LIST_VAR_SERVER OBJ_REBS_LIST_VAR_SERVER_P(_obj)
#define OBJ_REBS_LIST(o) (o GV [ROVAR, createHashMap])
#define OBJ_REBS_LIST_VAR PR _objRebs = OBJ_REBS_LIST(_obj);


#define GET_REB_INSTANCE(n) (METHOD(IOO_REB_DB, "Get_reb_class", n))
