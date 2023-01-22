module visual::ClassDependencies

import IO;
import Content;
import lang::html::IO;

import String;
import List;
import lang::java::jdt::m3::Core; 
import lang::java::m3::AST;

import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST;
import lang::java::flow::JavaToObjectFlow; 

import IO;
import vis::Figure; 
import vis::Render;


import metrics::Volume;
import metrics::UnitTests;
import metrics::UnitSize;
import metrics::UnitComplexity;
import metrics::Duplication;
import metrics::UnitTests;
import lang::json::IO;


@doc{
  ```rascal-shell
    import visual::ClassDependencies;
    list[Dependency] dependencyGraphData = readJSON(#list[Dependency], |project://MyRascal/src/output/dependencies.json|);
    makeDependencyVisualisation(dependencyGraphData);
  ```
}

@doc{
  function that generates class dependencies of a project and save the result to disk
}
public void generateClassDependencies(loc project){
  M3 m = createM3FromEclipseProject(project);
  edges = [edge("<to>", "<from>") | <from,to> <- m@typeDependency ];  
  classEdges = [];
  allClasses = {};
  
  str javaClassSignature = "|java+class:///";
  str projectName = split("/",replaceFirst(edges[0].from, javaClassSignature, ""))[0];
  str combinedName = replaceFirst("<javaClassSignature><projectName>/", "|", "");  
  
  for(e <- edges)
  {
	  if(contains(e.from, combinedName) && contains(e.to, combinedName))
	  {
	  	classEdges += e;
	  	allClasses += replaceAll(e.from, combinedName, "");
	  	allClasses += replaceAll(e.to, combinedName, "");
	  }
  }
    
  list[Dependency] dependencies = [];
  
  for(c <- allClasses)
  {
  	  tos = { replaceAll(e.to, combinedName, "") | e <- classEdges, replaceAll(e.from, combinedName, "") == c };
  	  dependencies += dependency(c, tos, 1);
  }
  
  writeJSON(|project://MyRascal/src/output/dependencies.json|, dependencies);
}

@doc{
  An ADT to encapsuate a dependency between classes
}
data Dependency = dependency(str name, set[str] imports, int size); 

@doc{
  GraphData encapsulates a list of dependencies that for the graphs' data
}
data GraphData = visualizeDependencies(list[Dependency] graphData);

@doc{
  given a list of dependencies the makeDependencyVisualisation function creates a content fragment.

  The content has a title and it requires a httpserver. The httpserver takes the above ADT as a parameter.

  See:
    - https://www.rascal-mpl.org/docs/Library/Content/
}
Content makeDependencyVisualisation(list[Dependency] v) = content("Dependencies", httpServer(visualizeDependencies(v)));

@doc{
  The httpserver is where the magic happens.
}
Response (Request) httpServer(GraphData graphData) {
  @doc{
    The reply function creates an endpoint onto which the graphData is returned as a JSON string
  }
  Response reply(get(/^\/chart/)) {
  
    return response(graphData);
  }

  @doc{
    The default reply is the one returned when the browser visits any other url.

      Using writeHTMLString a definition of a HTML page is written to the caller.
  }
  default Response reply(get(_)) {
  
    return response(writeHTMLString(plotHTML()));
  }
  return reply;
}

@doc{
  plotHTML is the wrapper for all the javascript logic. Load your libraries here.
  This is also where you actually make your visualisations.

  In the current code only the data is logged to the console (F12).
}
private HTMLElement plotHTML()
= html([
        div([
             script([], src="https://d3js.org/d3.v4.min.js")
             ]),
        body([
                      style([
                      \data(
                            "
'.legend-color-div {
'  width: 40px;
'  height: 5px;
'  display: inline-block;
'  margin: 0px 10px;
'  vertical-align: middle;
'}
'
'.legend-div {
'  font: 300 11px \"Helvetica Neue\", Helvetica, Arial, sans-serif;
'}
'.node {
'  font: 300 11px \"Helvetica Neue\", Helvetica, Arial, sans-serif;
'  fill: #bbb;
'}
'
'.node:hover {
'  fill: #000;
'}
'
'.link {
'  stroke: steelblue;
'  stroke-opacity: 0.4;
'  fill: none;
'  pointer-events: none;
'}
'
'.node:hover,
'.node--source,
'.node--target {
'  font-weight: 700;
'}
'
'.node--source {
'  fill: #2ca02c;
'}
'
'.node--target {
'  fill: #d62728;
'}
'
'.link--source,
'.link--target {
'  stroke-opacity: 1;
'  stroke-width: 2px;
'}
'
'.link--source {
'  stroke: #d62728;
'}
'
'.link--target {
'  stroke: #2ca02c;
'}
"
                      )
            ]),
              script([
                      \data(
                            "
'// Read data
var classLinks = [];
'd3.json(\"/chart\", function(error, data) {
'  if (error) throw error;
'  classLinks = data.graphData;
" + readFile(|project://MyRascal/src/js/dependencies.js|) + "
'});"
                      )
            ], \type="text/javascript")
        ] )
    ]);