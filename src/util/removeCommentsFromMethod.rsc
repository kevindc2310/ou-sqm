module util::removeCommentsFromMethod

import List;
import IO;

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