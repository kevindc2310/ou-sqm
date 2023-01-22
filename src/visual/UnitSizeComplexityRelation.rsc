module visual::UnitSizeComplexityRelation

import IO;
import lang::html::IO;
import lang::json::IO;
import Content;

@doc{
  ```rascal-shell
    import visual::UnitSizeComplexityRelation;
    import lang::json::IO;
    list[Point] complexityGraphData = readJSON(#list[Point], |project://MyRascal/src/output/complexitysizes.json|);
    makeVisualisation(complexityGraphData);
  ```
}

@doc{
  An ADT to encapsuate a single point
}
data Point = point(num x, num y, str tooltip);

@doc{
  GraphData encapsulates a list of points that for the graphs' data
}
data GraphData = visualize(list[Point] graphData);

@doc{
  given a set of points the makeVisualisation function create a content fragment.

  The content has a title and it requires a httpserver. The httpserver takes the above
    ADT as a parameter.

  See:
    - https://www.rascal-mpl.org/docs/Library/Content/
}
Content makeVisualisation(list[Point] v) = content("Scatter", httpServer(visualize(v)));

@doc{
  The httpserver is where the magic happens.
}
Response (Request) httpServer(GraphData graphData) {
  @doc{
    The reply function creates an endpoint onto which the graphData is returned as
      a JSON string
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
println(reply);
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
             script([], src="https://d3js.org/d3.v7.min.js")
             ]),
        body([
              div([], id="my_dataviz"),
              script([
                      \data(
                            "
'// Read data
'var scatterdata = [];
'd3.json(\"/chart\").then(function(data) {
'  scatterdata = data.graphData;
" + readFile(|project://MyRascal/src/js/scatter.js|) + "
'})"

                      )
            ], \type="text/javascript")
        ] )
    ]);