// set the dimensions and margins of the graph
var margin = {top: 10, right: 30, bottom: 50, left: 60},
    width = 1200 - margin.left - margin.right,
    height = 800 - margin.top - margin.bottom;

// append the svg object to the body of the page
var svg = d3.select("#my_dataviz")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");
var scatter;

  // Add X axis
  var x = d3.scaleLinear()
    .domain([0, 45])
    .range([ 0, width  ]);
  svg.append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));
	

  // Add Y axis
  var y = d3.scaleLinear()
    .domain([0, 120])
    .range([ height, 0]);
  svg.append("g")
    .call(d3.axisLeft(y));
	
	// Add X axis label:	
	svg.append("text")
    .attr("text-anchor", "end")
    .attr("x", width)
    .attr("y", height + margin.top + 30)
    .text("Cyclomatic complexity");

	// Y axis label:
	svg.append("text")
    .attr("text-anchor", "end")
    .attr("transform", "rotate(-90)")
    .attr("y", -margin.left+20)
    .attr("x", -margin.top)
    .text("Unit size");
	
	// Add a tooltip div. Here I define the general feature of the tooltip: stuff that do not depend on the data point.
  // Its opacity is set to 0: we don't see it by default.
  var tooltip = d3.select("#my_dataviz")
    .append("div")
    .style("opacity", 0)
    .attr("class", "tooltip")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "1px")
    .style("border-radius", "5px")
    .style("padding", "10px")



  // A function that change this tooltip when the user hover a point.
  // Its opacity is set to 1: we can now see it. Plus it set the text and position of tooltip depending on the datapoint (d)
  var mouseover = function(d) {
    tooltip
      .style("opacity", 1)
  }

  var mousemove = function(e,d) {
	  var unit = d.getAttribute("unit");
    tooltip
      .html(unit)
      .style("left", e.layerX+15 ) // It is important to put the +90: other wise the tooltip is exactly where the point is an it creates a weird effect
      .style("top", e.layerY)
	  .style("position", "absolute")
  }

  // A function that change this tooltip when the leaves a point: just need to set opacity to 0 again
  var mouseleave = function(d) {
    tooltip
      .transition()
      .duration(200)
      .style("opacity", 0)
  }

	setTimeout(() => {  
	
	// Add dots
  scatter = svg.append('g')
    .selectAll("dot")
    .data(tmp)
    .enter()
    .append("circle")
      .attr("cx", function (d) { return x(d.x); } )
      .attr("cy", function (d) { return y(d.y); } )
	  .attr("unit", function (d) { return d.tooltip } )
      .attr("r", 3)
      .style("fill", "#69b3a2")
	  .on("mouseover", mouseover )
	  .on("mousemove", function (e) { return mousemove(e,this);} )
      .on("mouseleave", mouseleave )
	  

	
}, 500);
	

  

