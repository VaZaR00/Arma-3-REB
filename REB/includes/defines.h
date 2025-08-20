#include "generic.h"
#include "oop.h"
#include "main.h"

#define ISLANCET ("lancet_tripod_launcher" in (typeOf vehicle player))
#define ISLANCETHANDL (ISLANCET && dialog)


/*
    MAIN REB MACRO DEFINES
*/
#define PREF_FNC PREF##_fnc_
#define FUNC(f) PREF_FNC##f
#define QFUNC(f) (MGVAR [STR(PREF_FNC) + f, {}])
#define REB_CLS_PREF "REB_CLASS_"
#define REB_VAR_PREF "REB_VAR_"
#define REB_OBJ_PREF "REB_OBJECT_CLASS_"
#define RC_PREF(s) (REB_CLS_PREF + s)