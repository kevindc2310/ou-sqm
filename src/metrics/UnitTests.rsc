module metrics::UnitTests

import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;
import util::M3;
import IO;
import List;
import util::String;
import util::javaFiles;
import util::Calculator;
import Map;
import Set;
import util::Math;

@doc{
  function that calculates unit size score score of a project, currently not used
}
public void calculateUnitTestCoverage(loc project){
	M3 model = createM3FromEclipseProject(project);
	set[loc] bestanden = javaFiles(project);
   
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
	
   lrel[str, Statement] result = [];
   list[str] methodList = [];
   countNonTestMethods = 0;
   assertedMethods = 0;
   totalAsserts = 0;
   totalLines = 0;
   assertedLines = 0;
   visit (decls) {
      case \method(_, name, _, _, impl): {
      		//model.containment[myTree.decl]
          list[str] lines = readFileLines(impl.src);
		  lines = removeNonCodeFromText(lines);
		  totalLines += size(lines);
          asserts = countAsserts(lines);
          if(asserts > 0) {
              methodList += name;
              assertedMethods += 1;
              totalAsserts += asserts;
              assertedLines += size(lines);
              println(impl);
          }
          else{
              countNonTestMethods += 1;
          }
      }
   }
   
   println("number of non asserted methods: <countNonTestMethods>");
   println("number of asserted methods: <assertedMethods>");
   println("number of total asserts: <totalAsserts>");
   println("number of total lines: <totalLines>");
   println("number of total asserted lines: <assertedLines>");
}

int countAsserts(list[str] lines) {
    int result = 0;

	   for(line <- lines)
	   {
	      if(/assert(True|Equals|False|ArrayEquals|Null|NotNull|Same|NotSame|That|\()/ := line) {
	      		//println(line);
	          result +=1;
	      }
	}
	return result;
}