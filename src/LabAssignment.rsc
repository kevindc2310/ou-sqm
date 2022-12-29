module LabAssignment

import IO;
import List;
import metrics::Volume;
import metrics::UnitTests;
import metrics::UnitSize;
import metrics::UnitComplexity;
import metrics::Duplication;
import metrics::UnitTests;
import util::Math;

//loc project = |project://smallsql0/|;
loc project = |project://smallsql0.21_src.zip_expanded|;
//loc project = |project://hsqldb|;

public void runAnalysis(){
    //calculateUnitTestCoverage(project);

	
	println("SmallSQL");
	//println("HyperSQL");
	println("----");
		
    volumeScore = calculateVolume(project);
    unitSizeScore = calculateUnitSize(project);
    complexityScore = calculateCc(project);
    duplicationScore = calculateDuplication(6, project);
    
    map[int, str] scoreStrings = (0:"--",1:"-",2:"o",3:"+",4:"++");
    
    println();
    println("volume score: <scoreStrings[volumeScore]>");
    println("unit size score: <scoreStrings[unitSizeScore]>");
    println("unit complexity score: <scoreStrings[complexityScore]>");
    println("duplication score: <scoreStrings[duplicationScore]>");
    
    list[int] analysabilityProperties = [volumeScore, unitSizeScore, duplicationScore];
    list[int] changeabilityProperties = [complexityScore, duplicationScore];
    list[int] stabilityProperties = [];
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
