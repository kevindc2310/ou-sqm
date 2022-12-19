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

// Helper functions

public set[loc] javaFiles(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}
public lrel[str, Statement] methodenAST(loc project) {
   set[loc] bestanden = javaFiles(project);
   
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   nonMethod = 0;
   visit (decls) {
      case \initializer(impl): result += <"initializer", impl>;
      case \method(_, name, _, _, impl): result += <name, impl>;
      case \constructor(name, _, _, impl): result += <name, impl>;
      default: nonMethod += 1;
   }
   println(nonMethod);
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
public list[str] removeCommentsAndWhiteLinesFromMethod(list[str] method){
	if(size(method) <= 1) return method;	
	list[str] methodWithout = removeCommentsFromMethod(method);
	methodWithout = removeWhiteLinesFromMethod(methodWithout);
	/*if(method != methodWithout){
		writeFileLines(|project://MyRascal/src/comments.txt|, file);
		writeFileLines(|project://MyRascal/src/nocomments.txt|, fileWithout);
		
	}*/
	 //println(size(methodWithout));
	return methodWithout;
}

public void printMethods(loc project) {
	M3 model = createM3FromEclipseProject(project);
	for (loc l <- methods(model)) {
		str s = readFile(l);
		println("=== <l> ===\n<s>");
	}
}
int calcCC(Statement impl) {
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
// End Helper functions
// Calculation functions
public void calculateUnitSize(){
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
	map[loc, int] regelsWithoutWhiteOrComment =( a:size(removeCommentsAndWhiteLinesFromMethod(readFileLines(a))) | a <- methods(model) );
	//println(sort(toList(regels), aflopend));
	//for (<a, b> <- sort(toList(regels), aflopend))
      //println("<a.file>: <b> regels");
    int numSimple = 0;
    int numModerate = 0;
    int numHigh = 0;
    int numVeryHigh = 0;
    //We berekenen nu het aantal lines source code. 
    for (<a, b> <- sort(toList(regelsWithoutWhiteOrComment))){
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
public void calculateCc(){
    allMethods = methodenAST(project);
    
    numberOfMethods2 = size(allMethods);
	println("Aantal methoden2:");
	println(numberOfMethods2);
    cc = 0;
    
    result = sort([<name, calcCC(s)> | <name, s> <- allMethods ], aflopend);
    
    // threshold waarden volgens sig
	int simpleCC = 10;
	int moderateCC = 20;
	int highCC = 50;
	
	int numSimpleCC = 0;
    int numModerateCC = 0;
    int numHighCC = 0;
    int numVeryHighCC = 0;
    
    
    for (<a, b> <- sort([<name, calcCC(s)> | <name, s> <- allMethods ], aflopend)){
    	if (b <= simpleCC)
    	{
    		numSimpleCC += 1;
    		continue;
    	}
    	if (b <= moderateCC)
    	{
    		numModerateCC += 1;
    		continue;
    	}
    	if (b <= highCC)
    	{
    		numHighCC += 1;
    		continue;
    	}
    	numVeryHighCC += 1;
    }
    
    println("CC:");
    println(" * simple: <numSimpleCC>");
    println(" * moderate: <numModerateCC>");
    println(" * high: <numHighCC>");
    println(" * very high: <numVeryHighCC>");
    
    
    //for (<a, b> <- allMethods){
    //	cc += calcCC(b);
    //}
    
    //println(cc);
}
public void runAnalysis(){
	println("SmallSQL");
	//println("HyperSQL");
	println("----");
	
    calculateUnitSize();
    calculateCc();
}

