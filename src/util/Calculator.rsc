module util::Calculator

import lang::java::m3::AST;
import util::String;
import IO;
import List;

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

int calcStatementsSize(Statement impl){
	list[str] lines = readFileLines(impl.src);
	lines = removeNonCodeFromText(lines);
	
	return size(lines);
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

/*public int countIf(Statement d) {
   int count = 0;
   visit(d) {
      case \if(_,_): count=count+1;
      case \if(_,_,_): count=count+1;
   } 
   return count;
}*/