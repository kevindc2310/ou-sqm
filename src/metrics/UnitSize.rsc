module metrics::UnitSize

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::javaFiles;
import util::methodenAST;
import IO;
import List;
import util::removeNonCodeFromText;
import util::calculateLocVolume;
import Map;
import Set;
import util::Math;
import visual::graphics;

public int calculateUnitSize(loc project){
	set[loc] bestanden = javaFiles(project);
	println("Aantal java files: <size(bestanden)>");
	M3 model = createM3FromEclipseProject(project);
	allMethods = methodenAST(project); // todo gebruik deze methodes voor de units
	numberOfMethods = size(allMethods);
	println("Aantal units: <numberOfMethods>");
	
	// threshold waarden volgens sig
	int simple = 15;
	int moderate = 30;
	int high = 60;
	map[loc, int] regels = ( a:size(readFileLines(a)) | a <- methods(model) );
	map[loc, int] regelsWithoutWhiteOrComment =( a:size(removeNonCodeFromText(readFileLines(a))) | a <- methods(model) );
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
    
    drawGraphic("UnitSize:",simplePercentage, moderatePercentage, highPercentage, veryHighPercentage);
    
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
