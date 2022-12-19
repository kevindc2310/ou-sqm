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
import util::Benchmark;



loc project = |project://smallsql0.21_src.zip_expanded|;
//loc project = |project://hsqldb|;

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
   //println(nonMethod);
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
  for(int i <- [0..(size(method) - 1)]){
      if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := method[i]){
          //print("");
          continue;
       } else {
       	  methodWithoutCommentLines += method[i] ;       	 
       }       
      } 
      return methodWithoutCommentLines;
}
public list[str] removeWhiteLinesFromMethod(list[str] method){
  list[str] methodWithoutWhiteLines = [];
  for(int i <- [0..(size(method) - 1)]){
      if(/^[ \t\r\n]*$/ := method[i]){
          //println("White line");
          continue;
       } else {
       	  methodWithoutWhiteLines += method[i] ;       	 
       }       
      } 
      return methodWithoutWhiteLines;
}
public list[str] removeCommentsAndWhiteLinesFromMethod(list[str] method){
	
	
	if(size(method) <= 1) return method;

	list[str] methodWithout = removeWhiteLinesFromMethod(method);
	methodWithout = removeCommentsFromMethod(methodWithout);
	/*if(method != methodWithout){
		writeFileLines(|project://MyRascal/src/comments.txt|, file);
		writeFileLines(|project://MyRascal/src/nocomments.txt|, fileWithout);
		
	}*/
	return methodWithout;
}
public list[str] removeImportOrPackagelLine(list[str] text){
	list[str] result = [];
	for(str line <- text){
		if(!/^import|^package/ := line) result += line;;
	}
	return result;
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
public int calculateVolume(){

	M3 model = createM3FromEclipseProject(project);

	int totalLines = 0;
	
	for(file <- files(model)){
		
		fileLines = readFileLines(file);
		fileLines = removeCommentsAndWhiteLinesFromMethod(fileLines);
		fileLines = removeImportOrPackagelLine(fileLines);
		totalLines += size(fileLines);
	}
	
	println("LOC: <totalLines>");
	
	// threshold waarden volgens sig voor java code
	int verySmall = 66000;
	int small = 246000;
	int moderate = 665000;
	int high = 1310000;
	
	if (totalLines <= verySmall)
    {
    	return 4;
    }
    if (totalLines <= small)
    {
    	return 3;
    }
    if (totalLines <= moderate)
    {
    	return 2;
    }
    if (totalLines <= high)
    {
    	return 1;
    }
	return 0;
}

public int calculateUnitSize(){
	set[loc] bestanden = javaFiles(project);
	println("Aantal java files: <size(bestanden)>");
	M3 model = createM3FromEclipseProject(project);
	numberOfMethods = size(methods(model));
	println("Aantal methoden: <numberOfMethods>");
	
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
    int totalLinesOfCode = 0;
    //We berekenen nu het aantal lines source code. 
    for (<a, b> <- sort(toList(regelsWithoutWhiteOrComment))){
    	totalLinesOfCode += b;
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
    
    simplePercentage = round(toReal(numSimple)/toReal(numberOfMethods)*100);
    moderatePercentage = round(toReal(numModerate)/toReal(numberOfMethods)*100);
    highPercentage = round(toReal(numHigh)/toReal(numberOfMethods)*100);
    veryHighPercentage = round(toReal(numVeryHigh)/toReal(numberOfMethods)*100);
    
    //real divideByTotal = cast(type[real],numberOfMethods);
    println("Unit size:");
    println(" * simple: <simplePercentage>%");
    println(" * moderate: <moderatePercentage>%");
    println(" * high: <highPercentage>%");
    println(" * very high: <veryHighPercentage>%");
    
    // score volgens sig methode berekenen 
    if(veryHighPercentage > 5 || highPercentage > 15 || moderatePercentage > 50) return 0;
    if(veryHighPercentage > 0 || highPercentage > 10 || moderatePercentage > 40) return 1;
    if(highPercentage > 5 || moderatePercentage > 30) return 2;
    if(moderatePercentage > 25) return 3;
    return 4;
    
}
public int calculateCc(){
    allMethods = methodenAST(project);
    
    numberOfMethods = size(allMethods);
	//println(numberOfMethods);
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
    
    //println(sort([<name, calcCC(s)> | <name, s> <- allMethods ], aflopend));
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
    
    simplePercentage = round(toReal(numSimpleCC)/toReal(numberOfMethods)*100);
    moderatePercentage = round(toReal(numModerateCC)/toReal(numberOfMethods)*100);
    highPercentage = round(toReal(numHighCC)/toReal(numberOfMethods)*100);
    veryHighPercentage = round(toReal(numVeryHighCC)/toReal(numberOfMethods)*100);
    
    println("CC:");
    println(" * simple: <simplePercentage>% (<numSimpleCC>)");
    println(" * moderate: <moderatePercentage>%(<numModerateCC>)");
    println(" * high: <highPercentage>%(<numHighCC>)");
    println(" * very high: <veryHighPercentage>%(<numVeryHighCC>)");
    
    // score volgens sig methode berekenen 
    if(veryHighPercentage > 5 || highPercentage > 15 || moderatePercentage > 50) 0;
    if(veryHighPercentage > 0 || highPercentage > 10 || moderatePercentage > 40) 1;
    if(highPercentage > 5 || moderatePercentage > 30) 2;
    if(moderatePercentage > 25) 3;
    return 4;
    
    
    //for (<a, b> <- allMethods){
    //	cc += calcCC(b);
    //}
    
    //println(cc);
}

public int calculateDuplication(int blockSize){
	M3 model = createM3FromEclipseProject(project);
	map[str, int] duplicationMap = ();
	list[str] duplicatedLinesResult = [];
	int duplicateBlocks = 0;
	int duplicateLines = 0;
	int totalLines = 0;
	
	for(file <- files(model)){
		bool insideDuplication = false;
		
		fileLines = readFileLines(file);
		fileLines = removeCommentsAndWhiteLinesFromMethod(fileLines);
		fileLines = removeImportOrPackagelLine(fileLines);
		if(size(fileLines) < blockSize) continue;
		totalLines += size(fileLines);
		list[str] codeLines = [];
		for(int n <- [0 .. size(fileLines)])
		{
			do
				codeLines += fileLines[n];
			while(size(codeLines) < blockSize);
			
			// omzetten naar een md5 hash, makkelijker leesbaar als key en neemt minder geheugen in beslag
			hashValue = md5Hash(codeLines);
			
			if(hashValue in duplicationMap){
				duplicationMap[hashValue] += 1;
				if(insideDuplication){
					duplicateLines += 1;
				}
				else
				{
					duplicateLines += blockSize;
					duplicateBlocks += 1;
					
				}
				if(duplicationMap[hashValue] >=1){
					duplicatedLinesResult += "File: <file>, Line:<n>";
					duplicatedLinesResult += codeLines + "\n\n";
					
				}
				insideDuplication = true;
			}
			else{
				duplicationMap[hashValue] = 0;
				insideDuplication = false;
			}
			
			codeLines = tail(codeLines);
		}
	}
	
	codeDuplication = round(toReal(duplicateLines)/toReal(totalLines)*100);
	
	//writeFileLines(|project://MyRascal/src/duplication.txt|, duplicatedLinesResult);
	println("duplicateBlocks: <duplicateBlocks>");
	println("duplicateLines: <duplicateLines>");
	println("totalLines: <totalLines>");
	println("Code duplication: <codeDuplication>%");
	
	if(codeDuplication > 20) return 0;
	if(codeDuplication > 10) return 1;
	if(codeDuplication > 5) return 2;
	if(codeDuplication > 3) return 3;
	return 4;
}

public void runAnalysis(){

	// onderstaande code voert benchmarking uit en berekent per methode het aantal ms
	/* 
	bm = benchmark(("volume" : void() { calculateVolume(); }, 
	"unit size" : void() { calculateUnitSize(); },
	"unit complexity" : void() { calculateCc(); },
	"duplication score" : void() { calculateDuplication(6); } ));
	println(bm);
	*/
	
	println("SmallSQL");
	//println("HyperSQL");
	println("----");
		
	volumeScore = calculateVolume();
	
    unitSizeScore = calculateUnitSize();
    complexityScore = calculateCc();
    duplicationScore = calculateDuplication(6);
    
    map[int, str] scoreStrings = (0:"--",1:"-",2:"o",3:"+",4:"++");
    
    println();
    println("volume score: <scoreStrings[volumeScore]>");
    println("unit size score: <scoreStrings[unitSizeScore]>");
    println("unit complexity score: <scoreStrings[complexityScore]>");
    println("duplication score: <scoreStrings[duplicationScore]>");
    
    list[int] analysabilityProperties = [volumeScore, unitSizeScore, duplicationScore];
    list[int] changeabilityProperties = [complexityScore, duplicationScore];
    //list[int] stabilityProperties = [];
    list[int] testabilityProperties = [complexityScore, unitSizeScore];
    
    analysability = round(toReal(sum(analysabilityProperties))/toReal(size(analysabilityProperties)));
    changeability = round(toReal(sum(changeabilityProperties))/toReal(size(changeabilityProperties)));
    //stability = round(toReal(sum(stabilityProperties))/toReal(size(stabilityProperties)));
    testability = round(toReal(sum(testabilityProperties))/toReal(size(testabilityProperties)));
    
    println();
    println("analysability: <scoreStrings[analysability]>");
    println("changeability: <scoreStrings[changeability]>");
    //println("stability: <scoreStrings[stability]>");
    println("testability: <scoreStrings[testability]>");
    
    list[int] maintainabilitySubScores = [analysability, changeability, testability];
    
    maintainability = round(toReal(sum(maintainabilitySubScores))/toReal(size(maintainabilitySubScores)));
    
    println();
    println("overall maintainability score: <scoreStrings[maintainability]>");

}

