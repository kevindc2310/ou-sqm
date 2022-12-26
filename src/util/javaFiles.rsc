module util::javaFiles

import util::Resources;
import lang::java::jdt::m3::Core; 

public set[loc] javaFiles(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}