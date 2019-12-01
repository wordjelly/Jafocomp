/***
data should be an array of json arrays
[
  {
    "key" : "2011",
    "color" : "red/green",
    "value" : 123
  },
  {
    "key" : "2012",
    "color" : "red/green",
    "value" : 445
  }
]
so this and the rest of the major stuff can be managed tomorrow.
today i want range tests out of the way
the range interpretation.
the js chart, and basic indicator information
and the 
***/
var draw_chart = function(data,max_obs){

  var width = 460
  var height = 460

  // append the svg object to the body of the page
  var svg = d3.select("#my_dataviz")
    .append("svg")
      .attr("width", width)
      .attr("height", height)

  // Read data
  //d3.csv("https://raw.githubusercontent.com/holtzy/data_to_viz/master/Example_dataset/11_SevCatOneNumNestedOneObsPerGroup.csv", function(data) {

    // the data is an array of values
    // each value
    // in our case will be like
    // "year" => "up","down"
    // so we want the size to equal the difference.
    // Filter a bit the data -> more than 1 million inhabitants
    data = data.filter(function(d){ return d.value>0 })

    // Color palette for continents?
    /****
    var color = d3.scaleOrdinal()
      .domain(["Asia", "Europe", "Africa", "Oceania", "Americas"])
      .range(d3.schemeSet1);
    ***/
    // Size scale for countries
    var size = d3.scaleLinear()
      .domain([0, max_obs])
      .range([7,55])  // circle will be between 7 and 55 px wide

    // create a tooltip
    var Tooltip = d3.select("#my_dataviz")
      .append("div")
      .style("opacity", 0)
      .attr("class", "tooltip")
      .style("background-color", "white")
      .style("border", "solid")
      .style("border-width", "2px")
      .style("border-radius", "5px")
      .style("padding", "5px")

    // Three function that change the tooltip when user hover / move / leave a cell
    var mouseover = function(d) {
      Tooltip
        .style("opacity", 1)
    }
    var mousemove = function(d) {
      Tooltip
        .html('<u>' + d.key + '</u>' + "<br>" + d.value + " inhabitants")
        .style("left", (d3.mouse(this)[0]+20) + "px")
        .style("top", (d3.mouse(this)[1]) + "px")
    }
    var mouseleave = function(d) {
      Tooltip
        .style("opacity", 0)
    }

    // Initialize the circle: all located at the center of the svg area
    var node = svg.append("g")
      .selectAll("circle")
      .data(data)
      .enter()
      .append("circle")
        .attr("class", "node")
        .attr("r", function(d){ return size(d.value)})
        .attr("cx", width / 2)
        .attr("cy", height / 2)
        .style("fill", function(d){ return d.color})
        .style("fill-opacity", 0.8)
        .attr("stroke", "black")
        .style("stroke-width", 1)
        .on("mouseover", mouseover) // What to do when hovered
        .on("mousemove", mousemove)
        .on("mouseleave", mouseleave)
        .call(d3.drag() // call specific function when circle is dragged
             .on("start", dragstarted)
             .on("drag", dragged)
             .on("end", dragended));

    // Features of the forces applied to the nodes:
    var simulation = d3.forceSimulation()
        .force("center", d3.forceCenter().x(width / 2).y(height / 2)) // Attraction to the center of the svg area
        .force("charge", d3.forceManyBody().strength(.1)) // Nodes are attracted one each other of value is > 0
        .force("collide", d3.forceCollide().strength(.2).radius(function(d){ return (size(d.value)+3) }).iterations(1)) // Force that avoids circle overlapping

    // Apply these forces to the nodes and update their positions.
    // Once the force algorithm is happy with positions ('alpha' value is low enough), simulations will stop.
    simulation
        .nodes(data)
        .on("tick", function(d){
          node
              .attr("cx", function(d){ return d.x; })
              .attr("cy", function(d){ return d.y; })
        });

    // What happens when a circle is dragged?
    function dragstarted(d) {
      if (!d3.event.active) simulation.alphaTarget(.03).restart();
      d.fx = d.x;
      d.fy = d.y;
    }
    function dragged(d) {
      d.fx = d3.event.x;
      d.fy = d3.event.y;
    }
    function dragended(d) {
      if (!d3.event.active) simulation.alphaTarget(.03);
      d.fx = null;
      d.fy = null;
    }

  //})
}