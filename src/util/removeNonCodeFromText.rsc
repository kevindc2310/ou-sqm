module util::removeNonCodeFromText

import List;
import util::removeCommentsFromMethod;
import util::removeNonCodeFromText;
import util::removeWhiteLinesFromMethod;
import util::removeImportOrPackagelLine;
import util::removeAbstractMethods;

public list[str] removeNonCodeFromText(list[str] method){
	if(size(method) <= 1) return method;	
	list[str] methodWithout = removeCommentsFromMethod(method);
	methodWithout = removeWhiteLinesFromMethod(methodWithout);
	methodWithout = removeImportOrPackagelLine(methodWithout);
	//methodWithout = removeAbstractMethods(methodWithout);
	return methodWithout;
}
