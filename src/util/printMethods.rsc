module printMethods

import lang::java::jdt::m3::Core; 

public void printMethods(loc project) {
	M3 model = createM3FromEclipseProject(project);
	for (loc l <- methods(model)) {
		str s = readFile(l);
		println("=== <l> ===\n<s>");
	}
}