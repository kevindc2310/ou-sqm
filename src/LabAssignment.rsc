module LabAssignment

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
// https://www.rascal-mpl.org/docs/Library/lang/java/m3/Core/
import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::Math;



loc project = |project://smallsql0.21_src.zip_expanded|;

public set[loc] javaFiles(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public lrel[str, Statement] methodenAST(loc project) {
   set[loc] bestanden = javaFiles(project);
   
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   visit (decls) {
      case \method(_, name, _, _, impl): result += <name, impl>;
      case \constructor(name, _, _, impl): result += <name, impl>;
   }
   return(result);
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
   return x[1] > y[1];
} 

public int countIf(Statement d) {
   int count = 0;
   visit(d) {
      case \if(_,_): count=count+1;
      case \if(_,_,_): count=count+1;
   } 
   return count;
}

public void printMethods(loc project) {
	M3 model = createM3FromEclipseProject(project);
	for (loc l <- methods(model)) {
		str s = readFile(l);
		println("=== <l> ===\n<s>");
	}
}

public void runAnalysis(){
	println("SmallSQL");
	println("----");
	set[loc] bestanden = javaFiles(project);
	println("Aantal java files:");
	println(size(bestanden));
	M3 model = createM3FromEclipseProject(project);
	numberOfMethods = size(methods(model));
	println("Aantal methoden:");
	println(numberOfMethods);
	// threshold waarden volgens sig
	int simple = 15;
	int moderate = 30;
	int high = 60;
	map[loc, int] regels = ( a:size(readFileLines(a)) | a <- methods(model) );
	//println(sort(toList(regels), aflopend));
	//for (<a, b> <- sort(toList(regels), aflopend))
      //println("<a.file>: <b> regels");
    int numSimple = 0;
    int numModerate = 0;
    int numHigh = 0;
    int numVeryHigh = 0;
    for (<a, b> <- sort(toList(regels))){
    	if (b <= simple)
    	{
    		numSimple += 1;
    		continue;
    	}
    	if (b <= moderate)
    	{
    		numModerate += 1;
    		continue;
    	}
    	if (b <= high)
    	{
    		numHigh += 1;
    		continue;
    	}
    	numVeryHigh += 1;
    }
    
    //real divideByTotal = cast(type[real],numberOfMethods);
    println("Unit size:");
    println(" * simple: <round(toReal(numSimple)/toReal(numberOfMethods)*100)>%");
    println(" * moderate: <round(toReal(numModerate)/toReal(numberOfMethods)*100)>%");
    println(" * high: <round(toReal(numHigh)/toReal(numberOfMethods)*100)>%");
    println(" * very high: <round(toReal(numVeryHigh)/toReal(numberOfMethods)*100)>%");
}

