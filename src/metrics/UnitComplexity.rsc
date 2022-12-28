module metrics::UnitComplexity

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::methodenAST;
import List;
import util::calculateLocVolume;
import util::calcCC;
import util::calcStatementsSize;
import util::Math;
import IO;
import visual::graphics;

public int calculateCc(loc project){
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
    
    simplePercentage = toReal(numSimpleLoc)/toReal(totalLinesOfCode)*100;
    moderatePercentage = toReal(numModerateLoc)/toReal(totalLinesOfCode)*100;
    highPercentage = toReal(numHighLoc)/toReal(totalLinesOfCode)*100;
    veryHighPercentage = toReal(numVeryHighLoc)/toReal(totalLinesOfCode)*100;
    
    drawGraphic("UnitComplexity:",simplePercentage, moderatePercentage, highPercentage, veryHighPercentage);
    
    println("CC:");
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
