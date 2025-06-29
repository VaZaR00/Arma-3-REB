
#include "defines.h"

CLASS("OO_TEST") 

	PUBLIC VARIABLE("string","Name");

	PUBLIC FUNCTION("","constructor") {
		MEMBER("Name", "aa");
		hint (MEMBER("Name", nil));
	};

	PUBLIC FUNCTION("","deconstructor") {};

	PUBLIC FUNCTION("","MT") {
		hint (MEMBER("Name", nil));
	};

ENDCLASS;