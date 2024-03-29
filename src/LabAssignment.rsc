module LabAssignment

import IO;
import String;
import List;

import lang::java::m3::AST;
import lang::java::flow::JavaToObjectFlow; 

import analysis::flow::ObjectFlow;

import vis::Figure; 
import vis::Render;

import util::Math;

import metrics::Volume;
import metrics::UnitTests;
import metrics::UnitSize;
import metrics::UnitComplexity;
import metrics::Duplication;
import metrics::UnitTests;

import visual::UnitSizeComplexityRelation;
import visual::ClassDependencies;

map[int, str] scoreStrings = (0:"--",1:"-",2:"o",3:"+",4:"++");

tuple[str name, loc location] Project = <"SmallSQL",|project://smallsql|>;
//tuple[str name, loc location] Project = <"HSQL DB",|project://hsqldb|>;

@doc{
  function that analyses the project declared above
}
public void runAnalysis(){
	println(Project.name);
	//println("HSQLDB");
	println("----");
		
    volumeScore = calculateVolume(Project.location);
    unitSizeScore = calculateUnitSize(Project.location);
    complexityScore = calculateCc(Project.location);
    duplicationScore = calculateDuplication(6, Project.location);
    //calculateUnitTestCoverage(project);
    
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




