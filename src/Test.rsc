module Test

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;

// Opgave 1-4: Opgaven in de REPL

// Opgave 5: Print Hello functie

public void exercise5() {
	println("Hello");
}


// Opgave 6: Regular expressions

list[str] eu = ["Austria", "Belgium", "Bulgaria", "Czech Republic",
   "Cyprus", "Denmark", "Estonia", "Finland", "France", "Germany",
   "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania",
   "Luxembourg", "Malta", "The Netherlands", "Poland",
   "Portugal", "Romania", "Slovenia", "Slovakia", "Spain",
   "Sweden", "United Kingdom"];

public void exercise6() {
   // land waarvan de naam een 's' bevat (case insensitive)
   println("(6a)");
   println({ land | land <- eu, /s/i := land });
   // land waarvan de naam minstens 2 keer 'e' bevat
   println("(6b)");
   println({ land | land <- eu, /e.*e/i := land });
   // land waarvan de naam precies 2 keer 'e' bevat
   println("(6c)");
   println({ land | land <- eu, /^([^e]*e){2}[^e]*$/i := land });
   // bevat geen 'n' en geen 'e'
   println("(6d)");
   println({ land | land <- eu, /^[^en]*$/i := land });
   // bevat een letter met tenminste twee voorkomens
   println("(6e)");
   println({ a | a <- eu, /<x:[a-z]>.*<x>/i := a });
   // bevat een 'a' (eerste wordt een o)
   println("(6f)");
   println({ begin+"o"+eind | a <- eu, /^<begin:[^a]*>a<eind:.*>$/i := a });
}


// Opgave 7: Functions on numbers

public rel[int, int] delers(int max) {
   return { <getal, deler> | getal <- [1..max], deler <- [1..max], getal % deler == 0 };
}

public void exercise7() {
   rel[int, int] d = delers(100);
   // relatie met delers
   println("(7a)");
   // println(d);
   // meeste delers
   println("(7b)");
   map[int, int] m = (a:size(d[a]) | a <- domain(d));
   // println("m:");
   // println(m);
   // println("range:");
   // println(range(m));
   int maxdiv = max(range(m)); 
   // println("max:");
   //println(maxdiv);
   println({ a | a <- domain(d), m[a] == maxdiv });
   // priemgetallen (oplopend)
   println("(7c)");
   
   // m[a] == 2 => aantal delers is 2, namelijk 1 en zichzelf
   println(sort([ a | a <- domain(m), m[a] == 2 ]));
}

// Opgave 8: Relaties

public Graph[str] relaties = {<"A", "B">, <"A", "D">, 
   <"B", "D">, <"B", "E">, <"C", "B">, <"C", "E">, 
   <"C", "F">, <"E", "D">, <"E", "F">};

public void exercise8() {

	// zie ook https://www.rascal-mpl.org/docs/Library/Relation/#Relation-range
   componenten = carrier(relaties);
   println("(8a)");
   println(size(componenten));
   println("(8b)");
   println(size(relaties));
   println("(8c)");
   println(top(relaties));
   println("(8d)");
   println((relaties+)["A"]);
   println("(8e)");
   println(componenten - (relaties*)["C"]);
   println("(8f)");
   println(( a:size(invert(relaties)[a]) | a <- componenten ));
}


// Opgave 9: The M3 meta model

public set[loc] javaFiles(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public lrel[str, Statement] methodenAST(loc project) {
   set[loc] bestanden = javaFiles(project);
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   visit (decls) {
      case \method(_, name, _, _, impl): result += <name, impl>;
      case \constructor(name, _, _, impl): result += <name, impl>;
   }
   return(result);
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
   return x[1] > y[1];
} 

public int countIf(Statement d) {
   int count = 0;
   visit(d) {
      case \if(_,_): count=count+1;
      case \if(_,_,_): count=count+1;
   } 
   return count;
}

public void exercise9() {
   //loc project = |project://Jabberpoint-le3|;
   loc project = |project://smallsql0.21_src.zip_expanded|;
   set[loc] bestanden = javaFiles(project);
   println("(9a)");
   println(size(bestanden));
   println("(9b)");
   map[loc, int] regels = ( a:size(readFileLines(a)) | a <- bestanden );
   for (<a, b> <- sort(toList(regels), aflopend))
      println("<a.file>: <b> regels");
   println("(9c)");
   M3 model = createM3FromEclipseProject(project);
   methoden =  { <x,y> | <x,y> <- model.containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor" 
                       };
   telMethoden = { <a, size(methoden[a])> | a <- domain(methoden) };
   for (<a,n> <- sort(telMethoden, aflopend))
      println("<a>: <n> methoden");
   println("(9d)");
   subklassen = invert(model.extends);
   telKinderen = { <a, size((subklassen+)[a])> | a <- domain(subklassen) };
   for (<a, n> <- sort(telKinderen, aflopend))
      println("<a>: <n> subklassen");
   println("(9e)");
   stats = methodenAST(project);
   numIf = sort([ <name, countIf(s)> | <name, s> <- stats ], aflopend);
   println(numIf[0]);
}


// Opgave 10: Visualising data

public list[&T] copy(int n, &T element) {
   return [ element | _ <- [0..n] ];
}

Figure redSquares  = hcat(copy(10, box(size(40), fillColor("red"))), gap(10), resizable(false));

public void exercise10a() {
   render("red squares", redSquares);
} 

public Figure shapeSwitch() {
   bool status = true;
   
   bool changeStatus(int butnr, map[KeyModifier,bool] modifiers) { 
      status = !status; 
      return true;
   };
   
   Figure s1 = box(size(40), fillColor("red"), resizable(false), onMouseDown(changeStatus));
   Figure s2 = ellipse(size(40), fillColor("green"), resizable(false), onMouseDown(changeStatus));
   
   // computefigure werkt niet op mijn toestel
   return computeFigure(Figure() {return status ? s1 : s2;});
}

public void exercise10b() {
   render("click on square", shapeSwitch());
} 

map[str, int] jabberSizes = 
   ("AboutBox.java":28, "Accessor":30, "BitmapItem":67, "DemoPresentation":50,
    "JabberPoint":37, "KeyController":44, "MenuController":109, "Presentation":107,
    "Slide":85, "SlideItem": 38, "SlideViewerComponent":62, "SlideViewerFrame":36,
    "Style.java":57, "TextItem.java":108, "XMLAccessor":112);

Figure jabberTreemap = treemap([ box(text(s),area(n),fillColor(arbColor())) | <s,n> <- toRel(jabberSizes) ]);

public void exercise10c() {
   render("JabberPoint treemap", jabberTreemap);
}
