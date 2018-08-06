// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//= require_tree .

/****
DISCLAIMER : I don't know ratshit about Javascript. This is as far as it goes. I'm a doctor, and God Bless America.
*****/


_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

_.templateSettings.variable = 'search_result'; 

var template;

$(document).on('keyup','#search',function(event){
	if( !$(this).val() ) {
		$("#logo").slideDown('fast',function(){

			$('#search_results').html("");
		});
		
	}
	else{
		if($('#logo').css('display') == 'none'){

		}
		else{
			$("#logo").slideUp('fast',function(){

				
			});

		}
	}
	search($(this).val());
});

var render_search_result = function(search_result){	
	if(_.isUndefined(template)){
		var template = _.template($('#search_result_template').html());
	}
	$('#search_results').prepend(template(search_result));
	$("time.timeago").timeago();
}

// now add the impacts and from tomorrow start developing the springapp for a live online version

var search = function(input){
	$.ajax({
	  url: "/search",
	  type: "GET",
	  dataType: "json",
	  data:{query: input}, 
	  success: function(response){
	  	//console.log("response");
	  	//console.log(response);
	    //clear existing search results
	    $('#search_results').html("");
	    results = JSON.parse(response["results"]);
	    _.each(results,function(search_result,index,list){
	    	search_result = update_bar_lengths(search_result);
	    	search_result = add_time_to_setup(search_result);
	    	render_search_result(search_result);
	    });
	  }
	});
}

/*****************
will return an object
{
	"bar_color" : "red/green",
	"bar_width" : Float, max 4
	"remaining_bar_width" : 4 - bar_width
}

We consider 4 rem as the max width of the whole bar
So use that as a percentage.
for eg if total up are 10, and total down are 4 REM.
then (10/14)*4 = 2.8 , will be the width for up, and that will be green.
and the rest will be the width for the down. 

*****************/
// we will modify the json object received.
// in the ajax call before rendering the template.
var update_bar_lengths = function(search_result){
	
	var base_rem = 20;
	
	var total_up = search_result.impacts[0].statistics[0].total_up;
	
	var total_down = search_result.impacts[0].statistics[0].total_down;
	
	var bar_color = "green";
	var bar_width = 0;
	var total = total_up + total_down;

	if(total_up >= total_down){
		bar_width = (total_up/total)*base_rem;
	}
	else{
		bar_color = "red";
		bar_width = (total_down/total)*base_rem;
	}
	
	var remaining_bar_width = base_rem - bar_width;
		
	search_result.impacts[0].statistics[0]["bar_width"] = bar_width;
	search_result.impacts[0].statistics[0]["bar_color"] = bar_color;
	search_result.impacts[0].statistics[0]["remaining_bar_width"] = remaining_bar_width;

	return search_result;
}

var add_time_to_setup = function(search_result){
	search_result.setup = search_result.setup  + " (" + strftime('%-d %b', new Date(search_result.triggered_at)) +  ")";
	return search_result;
}

$(document).on('click','.see_more',function(event){
	$(this).parent().prev('.card-content').find('.additional_info').first().slideToggle('fast',function(){
		
	});	
});
$(document).on('click','.simulate',function(event){
	$(this).parent().prev('.card-content').find('.trade_simulator').first().slideToggle('fast',function(){

	});
});