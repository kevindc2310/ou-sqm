module metrics::Volume

import lang::java::jdt::m3::Core; 
import util::Calculator;
import IO;

public int calculateVolume(loc project){
	M3 model = createM3FromEclipseProject(project);
	
	int totalLines = calculateLocVolume(model);
	println("LOC: <totalLines>");
		
	// threshold values according to SIG for Java projects
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