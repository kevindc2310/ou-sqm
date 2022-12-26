module util::calculateLocVolume

import lang::java::jdt::m3::Core; 
import IO;
import util::removeNonCodeFromText;
import List;
//import lang::java::m3::AST;

int calculateLocVolume(M3 model){
	int totalLines = 0;
	
	for(file <- files(model)){
		
		fileLines = readFileLines(file);
		fileLines = removeNonCodeFromText(fileLines);
		totalLines += size(fileLines);
	}
	return totalLines;
}