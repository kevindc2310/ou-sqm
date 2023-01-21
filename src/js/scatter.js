// some Rascal configurations wrap the objects and others don't, the code below solves this
if(scatterdata.length > 0 && scatterdata[0]["Point"] !== undefined){
  scatterdata = scatterdata.map(a => a.Point);
}

document.body.innerHTML += '<button onclick = "window.toggleColors();"> Toggle Maintainability zones </button>';

window.colorsVisible = false;

// set the dimensions and margins of the graph
window.margin = {top: 10, right: 0, bottom: 50, left: 60},
    width = 1200 - margin.left - margin.right,
    height = 800 - margin.top - margin.bottom;

window.domainX = Math.max(...scatterdata.map(o => o.x));
window.domainY = Math.max(...scatterdata.map(o => o.y));
if(domainX > 100) domainX = 100;
if(domainY > 160) domainY = 160;

// append the svg object to the body of the page
window.svg = d3.select("#my_dataviz")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");
   window.scatter;

  // Add X axis
  window.x = d3.scaleLinear()
    .domain([0, domainX])
    .range([ 0, width  ]);

    
  svg.append("g")
    .attr("class", "x")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));
	

  // Add Y axis
  window.y = d3.scaleLinear()
    .domain([0, domainY])
    .range([ height, 0]);
  svg.append("g")
  .attr("class", "y")
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

    window.showColors = function () {
      svg.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", width)
      .attr("height", height)
      .style("fill-opacity", 0.5)
      .style("fill", "red")
  
    svg.append("rect")
      .attr("x", 0)
      .attr("y", (domainY-60) / domainY * height) // 60 is big unit size
      .attr("width", 50 / domainX * width) // 50 is high complexity
      .attr("height", 60 / domainY * height)
      .style("fill-opacity", 0.5)
      .style("fill", "#ff8c00")
  
    svg.append("rect")
      .attr("x", 0)
      .attr("y", (domainY-30) / domainY * height) // 30 is moderate unit size
      .attr("width", 20 / domainX * width) // 20 is moderate complexity
      .attr("height", 30 / domainY * height)
      .style("fill-opacity", 0.5)
      .style("fill", "#f3ff00")
  
    svg.append("rect")
      .attr("x", 0)
      .attr("y", (domainY-15) / domainY * height) // 30 is small unit size
      .attr("width", 10 / domainX * width) // 20 is low complexity
      .attr("height", 15 / domainY * height)
      .style("fill-opacity", 0.5)
      .style("fill", "#00ff00")
    }
  
	
	// Add a tooltip div. Here I define the general feature of the tooltip: stuff that do not depend on the data point.
  // Its opacity is set to 0: we don't see it by default.
  window.tooltip = d3.select("#my_dataviz")
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
  window.mouseover = function(d) {
    tooltip
      .style("opacity", 1)
  }

  window.mousemove = function(e,d) {
	  var unit = d.getAttribute("unit");
    tooltip
      .html(unit)
      .style("left", e.layerX+15 ) // It is important to put the +90: other wise the tooltip is exactly where the point is an it creates a weird effect
      .style("top", e.layerY)
	  .style("position", "absolute")
  }

  // A function that change this tooltip when the leaves a point: just need to set opacity to 0 again
  window.mouseleave = function(d) {
    tooltip
      .transition()
      .duration(200)
      .style("opacity", 0)
  }

	
	// Add dots
  window.showDots = function () {
    scatter = svg.append('g')
    .selectAll("dot")
    .data(scatterdata)
    .enter()
    .append("circle")
      .attr("cx", function (d) { return x(d.x); } )
      .attr("cy", function (d) { return y(d.y); } )
	  .attr("unit", function (d) { return d.tooltip } )
      .attr("r", 3)
      .style("fill", "#0088ff")
	  .on("mouseover", mouseover )
	  .on("mousemove", function (e) { return mousemove(e,this);} )
      .on("mouseleave", mouseleave );
  }
  showDots();

  window.refreshChart = function() {
    x.domain([0, domainX]);
    y.domain([0, domainY]);
    d3.selectAll("g.y").call(d3.axisLeft(y));
    d3.selectAll("g.x").call(d3.axisBottom(x));
    svg.selectAll("circle").remove();
    svg.selectAll("rect").remove();
    if(colorsVisible) showColors();
    showDots();
  }

  window.zoomIn = function() {
    domainX /= 1.2;
    domainY /= 1.2;
    refreshChart();
  }

  window.zoomOut = function() {
    domainX *= 1.2;
    domainY *= 1.2;
    refreshChart();
  }

  window.toggleColors = function() {
    colorsVisible = !colorsVisible;
    refreshChart();
  }

  document.getElementById("my_dataviz").addEventListener('wheel',function(event){
    if(event.deltaY > 1) zoomOut();
    if(event.deltaY < -1) zoomIn();
});


	

  

