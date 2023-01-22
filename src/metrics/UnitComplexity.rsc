module metrics::UnitComplexity

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::M3;
import List;
import util::Calculator;
import util::Math;
import IO;
import lang::json::IO;
import visual::StackedBar;
import visual::UnitSizeComplexityRelation;

@doc{
  function that calculates the cyclomatic complexity score of a project, returns a score between 0-4
}
public int calculateCc(loc project){
	M3 model = createM3FromEclipseProject(project);
    allUnits = getUnits(project);
    
    numberOfMethods = size(allUnits);
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
    int totalLinesOfUnitCode = 0;
    
    list[Point] graphData = [];
    
    for (<a, b, c> <- [<location, calcCyclomaticComplexity(s), calcStatementsSize(s)> | <location, s> <- allUnits ]){
    	graphData += point(b,c,a);
    	totalLinesOfUnitCode += c;
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
    
    simplePercentage = toReal(numSimpleLoc)/toReal(totalLinesOfUnitCode)*100;
    moderatePercentage = toReal(numModerateLoc)/toReal(totalLinesOfUnitCode)*100;
    highPercentage = toReal(numHighLoc)/toReal(totalLinesOfUnitCode)*100;
    veryHighPercentage = toReal(numVeryHighLoc)/toReal(totalLinesOfUnitCode)*100;
    
    drawGraphic("UnitComplexity",simplePercentage, moderatePercentage, highPercentage, veryHighPercentage);
    
    writeJSON(|project://MyRascal/src/output/complexitysizes.json|, graphData);
    
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
