$(document).ready(function(){
	//_.each([0,20,35,50,65,80,95,100],function(up,key,list){
	//	_draw(up,100-up,0,key);
	//});
});

//General idea from Maarten Lambrecht's block: http://bl.ocks.org/maartenzam/f35baff17a0316ad4ff6
function move(d,SQRT3,hexRadius) {
	var currentx = parseFloat(d3.select(this).attr("cx")),
		mode = d3.select(this).style("mix-blend-mode"),
		radius = d.r;

	//Randomly define which quadrant to move next
	var sideX = currentx > 0 ? -1 : 1,
		sideY = Math.random() > 0.5 ? 1 : -1,
		randSide = Math.random();

	var newx,
		newy;

	//Move new locations along the vertical sides in 33% of the cases
	if (randSide > 0.66) {
		newx = sideX * 0.5 * SQRT3 * hexRadius - sideX*radius;
		newy = sideY * Math.random() * 0.5 * hexRadius - sideY*radius;
	} else {
		//Choose a new x location randomly, 
		//the y position will be calculated later to lie on the hexagon border
		newx = sideX * Math.random() * 0.5 * SQRT3 * hexRadius;
		//Otherwise calculate the new Y position along the hexagon border 
		//based on which quadrant the random x and y gave
		if (sideX > 0 && sideY > 0) {
			newy = hexRadius - (1/SQRT3)*newx;
		} else if (sideX > 0 && sideY <= 0) {
			newy = -hexRadius + (1/SQRT3)*newx;
		} else if (sideX <= 0 && sideY > 0) {
			newy = hexRadius + (1/SQRT3)*newx;
		} else if (sideX <= 0 && sideY <= 0) {
			newy = -hexRadius - (1/SQRT3)*newx;
		}//else

		//Take off a bit so it seems that the circles truly only touch the edge
		var offSetX = radius * Math.cos( 60 * Math.PI/180),
			offSetY = radius * Math.sin( 60 * Math.PI/180);
		newx = newx - sideX*offSetX;
		newy = newy - sideY*offSetY;
	}//else

	//Transition the circle to its new location
	/***
	d3.select(this)
		.transition("moveing")
		.duration(3000 + 4000*Math.random())
		.ease("linear")
		.attr("cy", newy)
		.attr("cx", newx)
		.style("mix-blend-mode", "screen")
		.each("end", move);
	***/
}//function move


/// up out of 100
/// down out of 100
/// name of the file to save.
/// lets change the download folder.
var _draw = function(up,down,flat,index){
	
	var svg_container_id = "hexagon" + String(index);
	var canvas_id = "canvas" + String(index);
	// add a svg 
	$("<div id='" + svg_container_id + "'></div>").appendTo('body');
	// and a canvas element.
	$("<canvas id='"+ canvas_id +"' height='500' width='500' />").appendTo('body');

	var margin = {
		top: 10,
		right: 0,
		bottom: 10,
		left: 0
	};

	//var width = window.innerWidth - margin.left - margin.right - 10,
	var width = 400 - margin.left - margin.right - 10
	height = Math.min(400, window.innerHeight - margin.top - margin.bottom - 20);
				
	//SVG container
	var svg = d3.select('#' + svg_container_id)
		.append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	///////////////////////////////////////////////////////////////////////////
	/////////////////////// Calculate hexagon variables ///////////////////////
	///////////////////////////////////////////////////////////////////////////	

	var SQRT3 = Math.sqrt(3),
		hexRadius = Math.min(width, height)/2,
		hexWidth = SQRT3 * hexRadius,
		hexHeight = 2 * hexRadius;
	var hexagonPoly = [[0,-1],[SQRT3/2,0.5],[0,1],[-SQRT3/2,0.5],[-SQRT3/2,-0.5],[0,-1],[SQRT3/2,-0.5]];
	var hexagonPath = "m" + hexagonPoly.map(function(p){ return [p[0]*hexRadius, p[1]*hexRadius].join(','); }).join('l') + "z";
	console.log("hexagon path is:");
	console.log(hexagonPath);

	///////////////////////////////////////////////////////////////////////////
	////////////////////// Place circles inside hexagon ///////////////////////
	///////////////////////////////////////////////////////////////////////////	

	//Create a clip path that is the same as the top hexagon
	svg.append("defs").append("clipPath")
	    .attr("id", "clip")
	    .append("path")
	    .attr("d", "M" + (width/2) + "," + (height/2) + hexagonPath);

	//First append a group for the clip path, then a new group that can be transformed
	var circleWrapperOuter = svg.append("g")
		.attr("clip-path", "url(#clip)")
		.style("clip-path", "url(#clip)"); //make it work in safari

	var circleWrapperInner = circleWrapperOuter.append("g")
		.attr("transform", "translate(" + (width/2) + "," + (height/2) + ")")
		.style("isolation", "isolate");

	//var colors = ["#2c7bb6", "#00a6ca","#00ccbc","#90eb9d","#ffff8c","#f9d057","#f29e2e","#e76818","#d7191c"];
	var down_colors = ["#f44336","#b71c1c","#ff5252","#ff8f00","#ff9800"];
	var up_colors = ["#4caf50","#00897b","#006064","#558b2f"];
	var flat_colors = ["#FFFFFF"];
	var colors = ["#bdbdbd","#9e9e9e","#efebe9"];
	var total_circles = 100;

	var up_till = Math.abs((up/100)*total_circles);
	var down_till = Math.abs((down/100)*total_circles);
	var flat_till = Math.abs((flat/100)*total_circles);

	//Create dataset with random initial positions
	randStart = [];
	colors = [];
	for(var i = 0; i < total_circles; i++) {
		randStart.push({
			rHex: Math.random() * hexWidth,
			theta: Math.random() * 2 * Math.PI,
			r: 4 + Math.random() * 20
		});

		if(up_till > 0){
			colors.push(up_colors[Math.floor(Math.random()*up_colors.length)]);
			up_till--;
		}
		else{
			if(down_till > 0){
				colors.push(down_colors[Math.floor(Math.random()*down_colors.length)]);
				down_till--;
			}
			else{
				if(flat_till > 0){
					colors.push(flat_colors[Math.floor(Math.random()*flat_colors.length)]);
					flat_till--;
				}
			}
		}
	}

	//Background rectangle
	//knock off the animations.
	//forget it.
	//now i need to 
	circleWrapperInner.append("rect")
		.attr("x", -hexWidth/2)
		.attr("y", -hexHeight/2)
		.attr("width", hexWidth)
		.attr("height", hexHeight)
		.style("fill", "#FFFFFF");

	var circle = circleWrapperInner.selectAll(".dots")
		.data(randStart)
		.enter().append("circle")
		.attr("class", "dots")
		.attr("cx", function(d) { return d.rHex * Math.cos(d.theta); })
		.attr("cy", function(d) { return d.rHex * Math.sin(d.theta); })
	  	.attr("r", 0)
	  	.style("fill", function(d,i) {
	  		return colors[i%colors.length];
	  	})
		.style("opacity", 1)
		.style("stroke","none")
		.style("mix-blend-mode", "none")
		.each(move,SQRT3,hexRadius);

	circle.transition("grow")
		.duration(function(d,i) { return Math.random()*2000+500; })
		.delay(function(d,i) { return Math.random()*3000;})
		.attr("r", function(d,i) { return d.r; });

	///////////////////////////////////////////////////////////////////////////
	///////////////////////// Place Hexagon in center /////////////////////////
	///////////////////////////////////////////////////////////////////////////	

	//Place a hexagon on the scene
	svg.append("path")
		.attr("class", "circle")
		.attr("d", "M" + (width/2) + "," + (height/2) + hexagonPath)
		.style("stroke", "#ffbf00")
		.style("stroke-width", "4px")
		.style("fill", "none");

	///////////////////////////////////////////////////////////////////////////
	////////////////////// Circle movement inside hexagon /////////////////////
	///////////////////////////////////////////////////////////////////////////	
	// so imagine -> one poller starts 
	// then another one starts ->
	// memory drops 
	// you start a third one -> it crashes
	// you start a fourth -> it also crashes.
	// this is enough.
	svg.append("text")
      .text("algorini")
      .attr("font-family", "Arial")
      .attr("font-weight", "bold")
      .attr("font-size", "40px")
      .attr("x", hexWidth - 40)
      .attr("y", hexHeight)
      .attr("fill", "#ffbf00")
      .attr("stroke", "white")
      .attr("stroke-width", ".5px");


	//exportCanvasAsPNG("hexagon","test");
	//svg_to_canvas_to_png();
	file_name = "up_" + String(up);
	setTimeout(svg_to_canvas_to_dataURL,10000,svg_container_id,file_name,index);
}


function endall(transition, callback) { 
    if (typeof callback !== "function") throw new Error("Wrong callback in endall");
    if (transition.size() === 0) { callback() }
    var n = 0; 
    transition 
        .each(function() { ++n; }) 
        .each("end", function() { if (!--n) callback.apply(this, arguments); }); 
} 

// would it be better to show a chart image ?
// 

var svg_to_canvas_to_dataURL = function(svg_parent,file_name,index){
	var canvas_id = "canvas" + String(index);
	const canvas = document.getElementById(canvas_id);
    const ctx = canvas.getContext('2d');
    
	var v = canvg.Canvg.fromString(ctx, $('#' + svg_parent).find("svg").html());
	v.start();
	exportCanvasAsPNG(canvas_id,file_name);
}

function exportCanvasAsPNG(id, fileName) {

    var canvasElement = document.getElementById(id);

    var MIME_TYPE = "image/png";

    var imgURL = canvasElement.toDataURL(MIME_TYPE);

    var dlLink = document.createElement('a');
    dlLink.download = fileName;
    dlLink.href = imgURL;
    dlLink.dataset.downloadurl = [MIME_TYPE, dlLink.download, dlLink.href].join(':');

    document.body.appendChild(dlLink);
    dlLink.click();
    document.body.removeChild(dlLink);
}