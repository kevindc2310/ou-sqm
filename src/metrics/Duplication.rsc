module metrics::Duplication

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import Map;
import List;
import IO;
import util::removeNonCodeFromText;
import util::Math;

public int calculateDuplication(int blockSize, loc project){
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
	
	codeDuplication = toReal(duplicateLines)/toReal(totalLines)*100;
	
	//writeFileLines(|project://MyRascal/src/duplication.txt|, duplicatedLinesResult);
	//println("duplicateBlocks: <duplicateBlocks>");
	//println("duplicateLines: <duplicateLines>");
	//println("totalLines: <totalLines>");
	println("Code duplication: <round(codeDuplication)>%");
	
	if(codeDuplication > 20) return 0;
	if(codeDuplication > 10) return 1;
	if(codeDuplication > 5) return 2;
	if(codeDuplication > 3) return 3;
	return 4;
}