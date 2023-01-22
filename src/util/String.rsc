module util::String

import IO;
import List;

@doc{
  function that removes empty lines in a list of strings
}
public list[str] removeWhiteLinesFromMethod(list[str] method){
  list[str] methodWithoutWhiteLines = [];
  for(int i <- [0..(size(method) )]){
      if(/^[ \t\r\n]*$/ := method[i]){
          print("");
       } else {
       	  methodWithoutWhiteLines += method[i] ;       	 
       }       
      } 
      return methodWithoutWhiteLines;
}

@doc{
  function that removes commented lines in a list of strings
}
public list[str] removeCommentsFromMethod(list[str] method){
  list[str] methodWithoutCommentLines = [];
  for(int i <- [0..(size(method) )]){
      if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := method[i]){
    	if(/<x: .*><y: .*\/\/.*>/ := method[i]){
      	 method[i]=x;
      	 methodWithoutCommentLines += method[i] ; 
  	 	}      
        print("");
       } else {
       	  methodWithoutCommentLines += method[i] ;       	 
       }       
      } 
     return methodWithoutCommentLines;
}

@doc{
  function that removes empty lines, commented lines, import and package lines in a list of strings
}
public list[str] removeNonCodeFromText(list[str] method){
	if(size(method) <= 1) return method;	
	list[str] methodWithout = removeCommentsFromMethod(method);
	methodWithout = removeWhiteLinesFromMethod(methodWithout);
	methodWithout = removeImportOrPackagelLine(methodWithout);
	//methodWithout = removeAbstractMethods(methodWithout);
	return methodWithout;
}

@doc{
  function that removes import and package lines in a list of strings
}
public list[str] removeImportOrPackagelLine(list[str] text){
	list[str] result = [];
	for(str line <- text){
		if(!/^import|^package/ := line) result += line;;
	}
	return result;
}

