module util::removeWhiteLinesFromMethod

import List;
import IO;

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