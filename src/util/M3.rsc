module util::M3

import IO;
import lang::java::m3::AST;
import util::Resources;

@doc{
  function that returns all java files of a project
}
public set[loc] getJavaFiles(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

@doc{
  function that returns all units of a project
}
public lrel[str, Statement] getUnits(loc project) {
   set[loc] bestanden = getJavaFiles(project);
   
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   nonMethod = 0;
   visit (decls) {
      case \initializer(impl): result += <"<impl.src.path>: Initializer", impl>;
      case \method(_, name, _, _, impl): result += <"<impl.src.path>: <name>", impl>;
      case \constructor(name, _, _, impl): result += <"<impl.src.path>: <name>", impl>;
      default: nonMethod += 1;
   }
   return(result);
}

