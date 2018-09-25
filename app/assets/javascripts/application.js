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
	$('#search_results').append(template(search_result));
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
	    //results = JSON.parse(response);
	    
	    _.each(response['results'],function(search_result,index,list){
	    	search_result = search_result['_source'];
	    	console.log(search_result);
	    	search_result = update_bar_lengths(search_result);
	    	search_result = add_time_to_setup(search_result);
	    	search_result = strip_period_details_from_setup(search_result);
	    	search_result = update_falls_or_rises_text(search_result);
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

var update_falls_or_rises_text = function(search_result){
	_.each(search_result.impacts[0].statistics,function(statistic,key,list){
		var total_times = statistic.total_up + statistic.total_down;
		if(statistic.total_up >= statistic.total_down){
			statistic["up_down_text"] = "Rises " + statistic.total_up + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "green";
		}
		else{
			statistic["up_down_text"] = "Falls " + statistic.total_down + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "red";	
		}
	});
	return search_result;
}

var add_time_to_setup = function(search_result){
	var d = new Date(0);
	d.setUTCSeconds(search_result.triggered_at);
	search_result.setup = search_result.setup  + " (" + strftime('%-d %b', d) +  ")";
	return search_result;
}

var strip_period_details_from_setup = function(search_result){
	var pattern = /_period_start_\d+_period_end/g
	search_result.setup = search_result.setup.replace(pattern,'');
	return search_result;
}

$(document).on('click','.see_more',function(event){
	$(this).parent().prev('.card-content').find('.additional_info').first().slideToggle('fast',function(){
	});	
});


$(document).on('click','.plain_trading',function(event){
	
	$(this).parent().prev('.card-content').find('.plain_stats').first().slideToggle('fast',function(){

	});

});

$(document).on('click','.strategic_trading',function(event){
	
	$(this).parent().prev('.card-content').find('.strategic_stats').first().slideToggle('fast',function(){

	});

});


var quotes = {
	"Probabilities guide the decisions of the wise." : "Marcus Tullius Cicero, Roman Philosopher, 63 BC",
	"Because, there is no joy in the finite. True bliss is in the infinite" : "Chandogya Upanishad, 8 BCE",
	"There's nothing in the world so demoralizing as money" : "Sophocles, 497 BCE",
	"After a certain point, money is meaningless. It ceases to be the goal. The game is what counts" : "Aristotle Onassis, Greek Shipping Billionaire, married to Jackie Kennedy (1906 - 1975)",
	"Let your hook always be cast; in the pool where you least expect it, there will be a fish." : "Publius Ovidius Naso(Ovid), Roman Poet, 17 AD",
	"I paraphrase Lord Rothschild: ‘The time to buy is when there's blood on the streets.'" : "David Dreman  Author - Contrarian Investment Strategies: The Psychological Edge.",
	"Start a fight. Prove you're alive. If you don't claim your humanity you will become a statistic. You have been warned." : "Chuck Palahnuick - The Fight Club",
	"Remember, that you too, are a black swan" : "Nassim Nicholas Taleb, The Black Swan : The Impact of the Highly Improbable",
	"I have a 41-year track record of investing excellence… what do you have?" : "Bill Gross, Founder ~ PIMCO",
	"One should tread the sinless path and gather wealth." : "(Vajasaneya Samhita iv-9)(Vedas)",
	"The rich rules over the poor, and the borrower is the slave of the lender." : "Proverbs 22:7",
	"A man's worth is no greater than his ambitions." : "~ Marcus Aurelius, Roman Emperor",
	"We really can't forecast all that well, and yet we pretend that we can, but we really can't." : "Alan Greenspan" 
}

$(document).ready(function(){
	var quote = _.sample(Object.keys(quotes), 1);
	var quote_author = quotes[quote];
	console.log("Quote is:" + quote);
	console.log("Quote author is:" + quote_author);
	$("#quote").text(quote);
	$("#quote_author").text(quote_author); 
});
