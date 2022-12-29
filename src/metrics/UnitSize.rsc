module metrics::UnitSize

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::javaFiles;
import util::methodenAST;
import IO;
import List;
import util::removeNonCodeFromText;
import util::calculateLocVolume;
import util::calcStatementsSize;
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
    int totalLinesOfUnitCode = 0;
    
     for (<a, b> <- [<name, calcStatementsSize(s)> | <name, s> <- allMethods ]){
     	totalLinesOfUnitCode += b;
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
    
    simplePercentage = toReal(numSimpleLoc)/toReal(totalLinesOfUnitCode)*100;
    moderatePercentage = toReal(numModerateLoc)/toReal(totalLinesOfUnitCode)*100;
    highPercentage = toReal(numHighLoc)/toReal(totalLinesOfUnitCode)*100;
    veryHighPercentage = toReal(numVeryHighLoc)/toReal(totalLinesOfUnitCode)*100;
    
    drawGraphic("UnitSize:",simplePercentage, moderatePercentage, highPercentage, veryHighPercentage);
    
    //real divideByTotal = cast(type[real],numberOfMethods);
    println("Unit size:");
    println(" * simple: <round(simplePercentage)>%");
    println(" * moderate: <round(moderatePercentage)>%");
    println(" * high: <round(highPercentage)>%");
    println(" * very high: <round(veryHighPercentage)>%");
    
    // score volgens sig methode berekenen 
    if(veryHighPercentage > 5 || highPercentage > 15 || moderatePercentage > 50) return 0;
    if(veryHighPercentage > 0 || highPercentage > 10 || moderatePercentage > 40) return 1;
    if(highPercentage > 5 || moderatePercentage > 30) return 2;
    if(moderatePercentage > 25) return 3;
    return 4;
}
