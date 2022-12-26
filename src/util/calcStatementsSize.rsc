module util::calcStatementsSize

import lang::java::m3::AST;
import IO;
import List;
import util::removeNonCodeFromText;

int calcStatementsSize(Statement impl){
	list[str] lines = readFileLines(impl.src);
	lines = removeNonCodeFromText(lines);
	
	return size(lines);
}