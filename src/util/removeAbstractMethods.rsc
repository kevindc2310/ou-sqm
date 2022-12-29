module util::removeAbstractMethods

import IO;

public list[str] removeAbstractMethods(list[str] text){
	list[str] result = [];
	bool abstractMethod=false;
	int countBrackets=0;
	int countLines=0;
	for(str line <- text){
		if(/.*abstract.*/ := line){
		countLines=countLines+1;
			abstractMethod=true;
			countBrackets=countBrackets+1;
			//println("countLines= <countLines>");
			continue;
		}
		
		if(abstractMethod){
		countLines=countLines+1;
		//println("countLines= <countLines>");
			if(/\{\.*/ := line){
			countBrackets=countBrackets+1;
			continue;
			}
			if(/.*}.*/ := line){
			countBrackets=countBrackets-1;
				if(countBrackets==0){
				abstractMethod=false;
				continue;
				}
			continue;
			}
		}
		result += line;
	}
	//println(result);
	return result;
}