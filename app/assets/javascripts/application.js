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
	    	render_search_result(search_result);
	    });
	  }
	});
}

