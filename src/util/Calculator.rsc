module util::Calculator

import lang::java::m3::AST;
import util::String;
import IO;
import List;

@doc{
  function that calculates cyclomatic complexity of a unit
}
int calcCyclomaticComplexity(Statement impl) {
    int result = 1;
    visit (impl) {
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case \foreach(_,_,_) : result += 1;
        case \catch(_,_): result += 1;
        case \conditional(_,_,_): result += 1;
        case \infix(_,"&&",_) : result += 1;
        case \infix(_,"||",_) : result += 1;
    }
    return result;
}

@doc{
  function that calculates the size of a unit
}
int calcStatementsSize(Statement impl){
	list[str] lines = readFileLines(impl.src);
	lines = removeNonCodeFromText(lines);
	
	return size(lines);
}

@doc{
  function that calculates the LLOC of a project. Accepts an M3 model of a project
}
int calculateLocVolume(M3 model){
	int totalLines = 0;
	
	for(file <- files(model)){
		
		fileLines = readFileLines(file);
		fileLines = removeNonCodeFromText(fileLines);
		totalLines += size(fileLines);
	}
	return totalLines;
}