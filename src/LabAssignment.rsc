module LabAssignment

import IO;
import String;
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



//loc project = |project://smallsql0.21_src.zip_expanded|;
loc project = |project://hsqldb|;

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

public list[str] removeNonCodeFromText(list[str] method){
	if(size(method) <= 1) return method;	
	list[str] methodWithout = removeCommentsFromMethod(method);
	methodWithout = removeWhiteLinesFromMethod(methodWithout);
	//methodWithout = removeBracketLines(methodWithout);
	methodWithout = removeImportOrPackagelLine(methodWithout);
	/*if(method != methodWithout){
		writeFileLines(|project://MyRascal/src/comments.txt|, file);
		writeFileLines(|project://MyRascal/src/nocomments.txt|, fileWithout);
		
	}*/
	 //println(size(methodWithout));
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
// End Helper functions

// Calculation functions
public int calculateVolume(){

	M3 model = createM3FromEclipseProject(project);
	
	int totalLines = calculateLocVolume(model);
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
	map[loc, int] regelsWithoutWhiteOrComment =( a:size(removeNonCodeFromText(readFileLines(a))) | a <- methods(model) );
	//println(sort(toList(regels), aflopend));
	//for (<a, b> <- sort(toList(regels), aflopend))
      //println("<a.file>: <b> regels");
    int numSimpleLoc = 0;
    int numModerateLoc = 0;
    int numHighLoc = 0;
    int numVeryHighLoc = 0;
    int totalLinesOfCode = calculateLocVolume(model);
    //We berekenen nu het aantal lines source code. 
    list[str] result = [];
    for (<a, b> <- sort(toList(regelsWithoutWhiteOrComment))){
    	result += "<a>;<b>";
    	if (b <= simple)
    	{
    		numSimpleLoc += b;
    		continue;
    	}
    	if (b <= moderate)
    	{
    		numModerateLoc += b;
    		continue;
    	}
    	if (b <= high)
    	{
    		numHighLoc += b;
    		continue;
    	}
    	numVeryHighLoc += b;
    }
    
    //writeFileLines(|project://MyRascal/src/unitsize.txt|, result);
    
    simplePercentage = percent(numSimpleLoc,totalLinesOfCode);
    moderatePercentage = percent(numModerateLoc,totalLinesOfCode);
    highPercentage = percent(numHighLoc,totalLinesOfCode);
    veryHighPercentage = percent(numVeryHighLoc,totalLinesOfCode);
    
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
	M3 model = createM3FromEclipseProject(project);
    allMethods = methodenAST(project);
    
    numberOfMethods = size(allMethods);
	//println(numberOfMethods);
    cc = 0;
        
    // threshold waarden volgens sig
	int simpleCC = 10;
	int moderateCC = 20;
	int highCC = 50;
	
	int numSimpleLoc = 0;
    int numModerateLoc = 0;
    int numHighLoc = 0;
    int numVeryHighLoc = 0;
    int totalLinesOfCode = calculateLocVolume(model);
    
    //println(sort([<name, calcCC(s)> | <name, s> <- allMethods ], aflopend));
    for (<a, b, c> <- [<name, calcCC(s), calcStatementsSize(s)> | <name, s> <- allMethods ]){
    	if (b <= simpleCC)
    	{
    		numSimpleLoc += c;
    		continue;
    	}
    	if (b <= moderateCC)
    	{
    		numModerateLoc += c;
    		continue;
    	}
    	if (b <= highCC)
    	{
    		numHighLoc += c;
    		continue;
    	}
    	numVeryHighLoc += c;
    }
    
    simplePercentage = percent(numSimpleLoc,totalLinesOfCode);
    moderatePercentage = percent(numModerateLoc,totalLinesOfCode);
    highPercentage = percent(numHighLoc,totalLinesOfCode);
    veryHighPercentage = percent(numVeryHighLoc,totalLinesOfCode);
    
    println("CC:");
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
		fileLines = removeNonCodeFromText(fileLines);
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
	
	codeDuplication = percent(duplicateLines,totalLines);
	
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
	
	//println("SmallSQL");
	println("HyperSQL");
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

