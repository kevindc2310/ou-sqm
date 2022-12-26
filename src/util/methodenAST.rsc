module util::methodenAST

import lang::java::m3::AST;
import util::javaFiles;

public lrel[str, Statement] methodenAST(loc project) {
   set[loc] bestanden = javaFiles(project);
   
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   nonMethod = 0;
   visit (decls) {
      case \initializer(impl): result += <"initializer", impl>;
      case \method(_, name, _, _, impl): result += <name, impl>;
      case \constructor(name, _, _, impl): result += <name, impl>;
      default: nonMethod += 1;
   }
   //println(nonMethod);
   return(result);
}