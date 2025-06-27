/*
	Class: OO_OBJECT_REB_DB

	Description:
		class which handles variable "REB_objectRebs" of any object
*/

#include "defines.h"

#define ROVAR "REB_objectRebs"
#define OBJ_ROVAR PR _objRebs = OBJ_REBS_LIST;
#define SAVE_ROVAR _obj SV [ROVAR, _objRebs, true];

CLASS("OO_OBJECT_REB_DB") // IOO_OBJECT_REB_DB

	PUBLIC FUNCTION("","Remove") {
		GLOBALY
		
		// args types: [string / code / object]

		params["_obj", "_or"];

		PR _objectReb = METHOD(OO_OBJECT_REB, Get_object_reb, _this);

		IF_NIL_EX(_objectReb);

		OBJ_ROVAR

		_objRebs = _objRebs - [_objectReb];

		DELETE(_objectReb);

		SAVE_ROVAR
	};

	PUBLIC FUNCTION("","Add") {
		GLOBALY
		
		// args types: [string / code / object]

		params["_obj", "_or"];

		PR _objectReb = METHOD(OO_OBJECT_REB, Get_object_reb, _this);

		IF_NIL_EX(_objectReb);

		OBJ_ROVAR

		_objRebs pushBackUnique _objectReb;

		SAVE_ROVAR
	};

	PUBLIC FUNCTION("","Clear") {
		GLOBALY
		
		params["_obj"];

		OBJ_ROVAR

		_objRebs apply {
			DELETE(_x);
		};

		_obj SV [ROVAR, nil, true];
	};

ENDCLASS;