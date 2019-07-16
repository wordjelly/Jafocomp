//= require_tree .

/****
DISCLAIMER : I don't know ratshit about Javascript. This file, summarizes my knowledge of the subject. I'm a doctor, and God Bless America.
*****/

_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

_.templateSettings.variable = 'search_result'; 

var template;

var slide_down_logo = function(event){
	$("#logo").slideDown('fast',function(){

		$('#search_results').html("");
		$('.show_more_query_chips').remove();
		$('.query_chips').remove();
		$('.related_chips').remove();
		$('.default_sectors').first().show();
	});
}

$(document).on('click','.dedication',function(event){
	$(".dedication-text").first().slideToggle();
})
/***
clear the search bar if the clear icon is clicked.
***/
$(document).on('click','#clear_search',function(event){
	$("#search").val("");
	
	slide_down_logo();
			
	
});

// first lets get this shit to display at least.

$(document).on('keyup','#search',function(event){
	// if the event is space.
	// don't do anything.
	
	// handle backspace on empty.

	if(event.keyCode == 32){
		console.log("got space, doing nothing.");
	}
	else{
		if( !$(this).val() ) {
			slide_down_logo();
			
		}
		else{
			if($('#logo').css('display') == 'none'){

			}
			else{
				$("#logo").slideUp('fast',function(){

					
				});
				$(".default_sectors").first().hide();

			}
			search_new($(this).val());
		}
	}
});

/***
so how would this work exactly 
suppose i say buy gold when 
***/

var render_search_result = function(search_result){	
	if(_.isUndefined(template)){
		var template = _.template($('#search_result_template').html());
	}
	$('#search_results').append(template(search_result));
	$("time.timeago").timeago();
}

var render_categories = function(categories){
	var category_template = _.template($('#categories_template').html());
	$("#categories").append(category_template(categories));
}

var render_related_queries = function(related_queries){
	var related_queries_template = _.template($('#related_queries_template').html());
	$("#related_queries_holder").empty();
	$("#related_queries_title").show();
	$("#related_queries_holder").append(related_queries_template(related_queries));
}


function humanize(str) {
  var frags = str.split('_');
  for (i=0; i<frags.length; i++) {
    frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1);
  }
  return frags.join(' ');
}


// how to show gold as gold_gold_metals ?
// we have one option.
// save the data-entity-type also on the 

var prepare_information_title = function(information_title){
	// remove all underscores
	// remove period_start_period_end
	information_title = information_title.replace(/period_start_\d+_period_end/,'');
	information_title = information_title.replace(/_/,' ');
	// capitalize everything
	return humanize(information_title);
}





var build_setup = function(search_result){
	var complex_string = search_result.preposition + " ";
	
	//console.log("the search result information is:");
	//console.log(search_result.information);

	var time_subindicator_regexp = new RegExp(/first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/g);

	// first test the tags to see if they contain period_start_period_end.
	// then that is not a time based subindciator.
	var non_time_subindicator = new RegExp(/period_start_\d/g)

	// same thing is repeated below in the final else.
	if(non_time_subindicator.test(search_result.tags) == true){

		_.map(search_result.tags,function(tag,index){

			if(index == 0){
				complex_string =  complex_string + tag + "'s" + " ";
			}
			else if(index == 1){
				complex_string =  complex_string + tag + " ";
			}
			else{
				complex_string = complex_string + tag + " ";
			}
		});

	}
	else{

		if(time_subindicator_regexp.test(search_result.information) == true){

			// if any of the tags have 
			// period_start_period_end
			// then 
			_.map(search_result.tags,function(tag,index){
			
				complex_string = complex_string + tag + " ";
			
			});

		}
		else if(time_subindicator_regexp.test(search_result.tags) == true){

			console.log("got a time based subindicator, by checking the tags");
			_.map(search_result.tags,function(tag,index){
			
				complex_string = complex_string + tag + " ";
			
			});

		}
		else
		{
			// non time subindicator.
			_.map(search_result.tags,function(tag,index){

				if(index == 0){
					// full name.
					complex_string =  complex_string + tag + "'s" + " ";
				}
				else if(index == 1){
					// symbol
				}
				else{
					complex_string = complex_string + tag + " ";
				}
			});			
		}

	}


	//console.log("complex string becomes:");
	//console.log(complex_string);

	search_result.setup = search_result.setup + " " + complex_string;

	//search_result.setup = add_icons(search_result.setup);
	//console.log("setup becomes:");
	//console.log(search_result.setup);
}


var get_icon = function(setup){
	var oil_regex = new RegExp(/^buy\soil/gi)
	var gold_regex = new RegExp(/^buy\sgold/gi)
	var forex_regex = new RegExp(/^buy\s(EUR|USD|JPY)/gi)
	if(oil_regex.test(setup) == true){
		// add the oil icon at the start of the setup
		return "<i class='fas fa-tint'></i>";
	}
	else if(gold_regex.test(setup) == true){
		return "<i class='fas fa-balance-scale'></i>";
	}
	else if(forex_regex.test(setup) == true){
		return "<i class='fas fa-coins'></i>";
	}
	else{
		return "<i class='fas fa-industry'></i>";
	}
	return setup;
}


/***
@param[Object] search_result : the search result itself.
@param[Array] stats: from the suggestion split on commas.
sets the impacted categories using the suggestion input.
## we want to take up everything after the 
***/
var set_impacted_categories_from_suggestion_input = function(search_result,stats){
	console.log("stats are:");
	console.log(stats);
	var categories = stats.slice(12,stats.length);
	search_result.categories = categories;
	console.log("the search result categories are:");
	console.log(search_result.categories);
}

var set_related_queries_from_suggestion_input = function(search_result,related_queries){
	search_result.related_queries = related_queries.split(",");
}

/***
***/
var set_origin_categories = function(search_result){
	// this and also where to display them.
}


/***
getStats()[0] = week_total_up;
getStats()[1] = week_total_down;
getStats()[2] = week_max_profit;
getStats()[3] = week_max_loss;
getStats()[4] = month_total_up;
getStats()[5] = month_total_down;
getStats()[6] = month_max_profit;
getStats()[7] = month_max_loss;
getStats()[8] = six_month_total_up;
getStats()[9] = six_month_total_down;
getStats()[10] = six_month_max_profit;
getStats()[11] = six_month_max_loss;
***/
var assign_statistics = function(search_result,text){
	console.log("search result is:");
	console.log(search_result);
	/***
	if(_.isUndefined(text)){
		// so let's see if all this works.	
	}
	else{
		var text_split_on_space = text.split("#")[0].split(" ");
		console.log("text split on space:");
		console.log(text_split_on_space);
		search_result.suggest = _.filter(search_result.suggest,function(el){
			var satisfied = true;
			console.log("el input is:");
			console.log(el["input"]);
			_.each(text_split_on_space,function(word){
				if(satisfied == true){
					satisfied = (el['input'].indexOf(word) != -1);
				}
			});
			return satisfied;
		});
	}

	console.log("suggestions remaining");
	
	search_result.suggest = [_.first(search_result.suggest)];
	**/
	var suggestion = search_result.suggest[0];
	
	var related_queries = suggestion.input.split("%")[1];
	var pre = suggestion.input.split("%")[0];
	var information = pre.split("#");

	
	search_result.information = information;
	search_result.setup = "buy " + information[0].split(" ")[0];

	// so its splitting on the space.

	var stats = information[1];

	stats = stats.split(",");
	search_result.triggered_at = search_result.epoch;

	// this sets the 
	set_impacted_categories_from_suggestion_input(search_result,stats);
	set_related_queries_from_suggestion_input(search_result,related_queries);
	stats = stats.slice(0,12);
	
	build_setup(search_result);

	search_result.impacts = [];

	var impact = {
		statistics: []
	}

	/// add week.
	if((Number(stats[0]) == 0) && (Number(stats[1]) == 0)){

	}
	else{
		impact.statistics.push({
			time_frame: 7,
			time_frame_unit: "days",
			time_frame_name: "1 week",
			total_up: Number(stats[0]),
			total_down: Number(stats[1]),
			maximum_profit: Number(stats[2]),
			maximum_loss: Number(stats[3])
		})
	}

	/// and month
	if((Number(stats[4]) == 0) && (Number(stats[5]) == 0)){

	}
	else{
		impact.statistics.push({
			time_frame: 31,
			time_frame_unit: "days",
			time_frame_name: "1 month",
			total_up: Number(stats[4]),
			total_down: Number(stats[5]),
			maximum_profit: Number(stats[6]),
			maximum_loss: Number(stats[7])
		})
	}

	/// add year
	if((Number(stats[8]) == 0) && (Number(stats[9]) == 0)){

	}
	else{
		impact.statistics.push({
			time_frame: 180,
			time_frame_unit: "days",
			time_frame_name: "6 months",
			total_up: Number(stats[8]),
			total_down: Number(stats[9]),
			maximum_profit: Number(stats[10]),
			maximum_loss: Number(stats[11])
		})
	}


	search_result.impacts.push(impact);
		
}


// so is it an indicator, this can be done easily.
// what's next.
var word_is_indicator = function(word){
	var result = false;
	var indicators = ["_indicator","close","open","high","low","volume","aroon"];
	_.each(indicators,function(indicator){
		if(word.indexOf(indicator) != -1){
			result = true;
		}
	});
	return result;
}
/**
will analyze the siblings of the origin.
if indicator is before it, then it will send everything after indicator -> as the query.
if indicator is in it, then it will send only it.
if indicator is after it, 
***/
var prepare_query_for_tooltip_search = function(origin){
	var indicator_element = null;
	var subindicator_name = [];
	var query = null;
	if(origin.data("name").toString().indexOf("_indicator") != -1){
		console.log("making query from indicator");
		console.log("new query:");
		console.log(expand_indicators_for_information_query(origin.data("name")));
		query = expand_indicators_for_information_query(origin.data("name")).replace(/_period_start_\d+_(\d+_)*period_end/,"");
		console.log("query is:");
		console.log(query);
	}
	else{
		origin.prevAll().each(function(key,el){
			console.log("doing prevall");
			console.log(el);
			console.log($(el).data("name"));
			data_name = $(el).data("name");
			if(!_.isUndefined(data_name)){
				if(word_is_indicator(data_name.toString())){

					if(_.isNull(indicator_element)){
						indicator_element = el;
						//console.log("making query from indicator element");
					}
					//break;
				}
				else{
					if(_.isNull(indicator_element)){
						subindicator_name.push($(el).data("name"));
					}
				}
			}
		});


		console.log("subindicator name contains:");
		console.log(subindicator_name);

		if(!_.isNull(indicator_element)){
			console.log("there is an indicator name");
			query = subindicator_name.reverse().join(" ");
			query += " " + origin.data("name"); 
			origin.nextAll().each(function(key,el){
				// unless it has a bracket, or is a superscript.
				if($(el).prop("nodeName").indexOf("sup") == -1){
					query = query + " " + $(el).data("name");
				}

			})
		}
		else{
			// query  the element as long as its not a stopword.
			if(!_.has(stopwords,origin.data("name"))){
				query = origin.data("name");
			}
		}

	}

	// remove period_start_\d_period_end.
	// if it is there in the query.
	return restore_percentage_and_literal_names_for_information_query(query);
}



var display_search_results = function(search_results,input){
	$('#search_results').html("");
	$('#categories').html("");
	var categories = [];
	var related_queries = [];
	 // and later use a template to get this.
	_.each(search_results,function(search_result,index,list){
			// ALL THIS
			// upto the last matching entire word.
			// not incomplete words.
			// so if the search result's text is 
			// buy gold on
			// and your query is buy gold o
			// we want to stop till buy gold.
    	//console.log(search_result);
    	text = search_result["text"];
    	search_result = search_result['_source'];
    	
    	//console.log("search result is:");
    	//console.log(search_result);
    	//console.log("text is:");
    	//console.log(text);
    	//search_result['suggest'].reverse();
    	assign_statistics(search_result,text);
    	search_result = update_coin_counts(search_result);
    	search_result = update_bar_lengths(search_result);
    	search_result = convert_n_day_change_to_superscript(search_result);
    	search_result = replace_percentage_and_literal_numbers(search_result);
    	
    	// add the tooltip spans to each word.
    	//update_last_successfull_query(input,search_result.setup);
    	// only the thing about the sup is left.
    	// 
    	
    	search_result.setup = shrink_indicators(search_result.setup);
    	
    	var arr = search_result.setup.split(" ");
    	var concat = "";
    	_.each(arr,function(value,index){
    		if(index == 2){
    			concat+= ("<span class='blue-grey-text'>"+ "<span class='tooltip' title='" + value + "' data-name='" + value +"'> " + value + "</span>");
    		}
    		else{
    			concat+= ("<span class='tooltip' title='" + value + "' data-name='" + value +"'> " + value + "</span>");
    		}

    	});
    	concat += "</span>";
    	//pattern = /\s([A-Za-z0-9\-\_\/\\\.]+)/g
		//search_result.setup = search_result.setup.replace(pattern,' <span>$1</span>');
		// previous setup was :
		// 
		var icon = get_icon(search_result.setup);
		search_result.setup = icon + concat;	

		//search_result.setup = replace_pattern_with_icons(search_result.setup);	
		
    	search_result = strip_period_details_from_setup(search_result);
    	search_result = update_falls_or_rises_text(search_result);	
    	search_result = add_time_to_setup(search_result);
    	//console.log(search_result);
    	categories = _.union(search_result.categories,categories);
    	related_queries = _.union(search_result.related_queries,related_queries);
    	render_search_result(search_result);
    });

		$('.tooltip').tooltipster({
	    content: 'Loading...',
	    contentAsHTML: true,
		interactive: true,
	    // 'instance' is basically the tooltip. More details in the "Object-oriented Tooltipster" section.
	    functionBefore: function(instance, helper) {
	        
	        var $origin = $(helper.origin);

	       //prepare_query_for_tooltip_search($origin);

	        // we set a variable so the data is only loaded once via Ajax, not every time the tooltip opens
	        if ($origin.data('loaded') !== true) {

	        	// so origin is the span element.
	        	// first check if it has indicator before it or after it.
	        	// if indicator is before, then it is a subindicator, and we take everything after it.
	        	// but the exception so close, 

	            $.get('/search',{information: prepare_query_for_tooltip_search($origin)}).done(function(data) {

	            	console.log("data is:");
	            	console.log(data);
	            	if(!_.isEmpty(data["results"])){

	            		result = data["results"][0]["_source"];

		            	title_string = "<h5 class='white-text'>"+ prepare_information_title(result["information_name"]) +"</h5><br>";

		            	content_string = result["information_description"] + "<br>";

		            	link_string = '';

		            	if(!_.isEmpty(result["information_link"])){
		            		console.log("there is an information link");
		            		link_string = "<a href=\"" + result["information_link"] + "\">Read More</a>";
		            	}
		            	
		            	var content = title_string + content_string + link_string

		            	console.log("content" + content);

		                instance.content(content);
		               
		                $origin.data('loaded', true);

	            	}
	            	
	            });
	        }
	    }
	});
	render_categories(categories);
	render_related_queries(related_queries);
}

var query_pending = function(input){
	var already_running_query = $("#already_running_query").attr("data-already-running-query");
	//console.log("already running query is:");
	//console.log(already_running_query);
	if(!_.isEmpty(already_running_query)){
		$("#queued_query").attr("data-queued-query",input);
		return true;
	}
	else{	
		return false;
	}
}



var search_new = function(input){
	if(query_pending(input) == true){

	} 
	else{
		console.log("no pending query");
		var ajaxTime= new Date().getTime();
		$.ajax({
		  	url: "/search",
		  	type: "GET",
		  	dataType: "json",
		  	data:{query: input},
		  	beforeSend: function(){
		  	  
		  	  $("#progress_bar").css("visibility","visible");
		      $("#already_running_query").attr("data-already-running-query",input);
		    }, 
		  	success: function(response){
		  		var totalTime = new Date().getTime()-ajaxTime;

		  		console.log("server side took:" + totalTime);

		    	$('#search_results').html("");
		    	
		    	var search_results = response['results']['search_results'];

		    	display_search_results(search_results,input);

			},
			complete: function(){
				$("#progress_bar").css("visibility","hidden");
				$("#already_running_query").attr("data-already-running-query","");
				//console.log("unsetting already running query");
				//console.log($("#queued_query").attr("data-queued-query"));
				if(!_.isEmpty($("#queued_query").attr("data-queued-query"))){
					//console.log("firing search request again for queued query.");
					var queued_query = $("#queued_query").attr("data-queued-query");
					$("#queued_query").attr("data-queued-query","");
					search_new(queued_query);
				}
			}
		});
	}
}


/***
var update_last_successfull_query = function(query,result_text){
	if(!((_.isUndefined(query)) || (_.isNull(query)))){
		var successfull_query = "";
		//console.log("query is:" + query);
		//console.log("Result text:" + result_text);
		_.each(query.split(" "),function(word){
			var regex = new RegExp(word + "\\b");
			//console.log("Regex is:" + regex);
			if(regex.test(result_text) === true){
				//console.log("matches.");
				successfull_query += word + " ";
			}
		});
		//console.log("successfull_query is:" + successfull_query);
		if(!(_.isEmpty(successfull_query))){
			$("#last_successfull_query").attr("data-query",successfull_query);
		}
	}
}

var search = function(input){

	//console.log("--------- called search with input:" + input);

	var contexts_with_length = prepare_contexts(input);

	
	//console.log("contexts with length are:");
	//console.log(contexts_with_length);

	if(_.size(contexts_with_length) == 1){

		var context = input.replace(/\s{2}/g,'');
		
		context = context.replace(/\s/,':');

		contexts_with_length[context] = context.length;
	}


	$.ajax({
	  url: "/search",
	  type: "GET",
	  dataType: "json",
	  data:{query: _.last(input.split(" ")), context: contexts_with_length}, 
	  success: function(response){

	    $('#search_results').html("");
	    	
	    _.each(response['results'],function(search_result,index,list){
	    	search_result = search_result['_source'];
	    	//console.log(search_result);
	    	search_result = update_bar_lengths(search_result);
	    	search_result = add_time_to_setup(search_result);
	    	search_result = add_impact_and_trade_action_to_setup(search_result);
	    	search_result = add_tooltips_to_setup(search_result);
	    	search_result = strip_period_details_from_setup(search_result);
	    	search_result = update_falls_or_rises_text(search_result);
	    	search_result = set_stop_losses(search_result);
	    	console.log(search_result);
	    	if(index == 0){
	    		// check todo for this.
	    		$("#top_result_contexts").attr("data-context",JSON.stringify(search_result["suggest"]["contexts"]["chain"]));
	    	}
	    	render_search_result(search_result);
	    	
	    });

	  

	  }
	});


	

}
***/

// so this sup business does not work.
var update_coin_counts = function(search_result){
	var max_units = 9;
	if(!_.isEmpty(search_result.impacts[0].statistics)){
		var multiple = max_units/(_.size(search_result.impacts[0].statistics));
		console.log("multiple is:" + multiple);
		console.log("size of the statistics of the first impact is:");
		console.log(_.size(search_result.impacts[0].statistics));
		
		var gold = [];
		var total_time_units = [];
		_.each(search_result.impacts[0].statistics,function(statistic){
			if(statistic.total_up >= statistic.total_down){
				gold.push(_.range(Math.floor(multiple)));
			}
		});
		gold = _.flatten(gold);
		search_result.impacts[0].statistics[0]["gold_coins"] = gold;
		console.log("the gold coins become:");
		console.log(gold);
		search_result.impacts[0].statistics[0]["other_coins"] = _.range(max_units - gold.length);
	}
	return search_result;
}

// i need to color and linkify the company names


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
// let's do this based on how many are positive and how many are negative.
var update_bar_lengths = function(search_result){
	// abbreviate all indicators
	// like williams R indicator WR indicator.
	// 
	var green = 0;
	var red = 0;
	_.each(search_result.impacts[0].statistics,function(statistic){
		// we want the best of three for these.
		if(statistic.total_up > statistic.total_down){
			green = green + 1;
		}
		else if(statistic.total_up < statistic.total_down){
			red = red + 1;
		}
	});

	var base_rem = 20;
	var bar_color = "green";
	var bar_width = 0;
	
	var total = green + red;

	if(green >= red){
		bar_width = (green/total)*base_rem;
	}
	else{
		bar_color = "red";
		bar_width = (red/total)*base_rem;
	}


	
	/***
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
	**/


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
			statistic["up_down_text"] = "<i class='material-icons'>call_made</i>Rises " + statistic.total_up + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "green";
		}
		else{
			statistic["up_down_text"] = "<i class='material-icons'>call_received</i>Falls " + statistic.total_down + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "red";	
		}
	});
	return search_result;
}

var add_time_to_setup = function(search_result){
	var d = new Date(0);
	d.setUTCSeconds(search_result.triggered_at);
	search_result.setup = search_result.setup  + " (" + strftime('%-d %b %Y', d) +  ")";
	return search_result;
}

var convert_n_day_change_to_superscript = function(search_result){
	var pattern = /(\d+)\sday\schange/
	var match = pattern.exec(search_result.setup);
	search_result.setup = search_result.setup.replace(pattern,'');
	if(!_.isNull(match)){
		search_result.setup = search_result.setup + "<sup>" + match[1] + "</sup>";
	}
	return search_result;
}


var strip_period_details_from_setup = function(search_result){
		
	var pattern = /(<.+?>[^<>]*?)(_period_start_\d+(_\d+)?_period_end)([^<>]*?<.+?>)/g
	
	var match = pattern.exec(search_result.setup);
	if(!_.isNull(match)){
		//console.log("match is:");
		//console.log(match);
		if(match.length == 5){
			search_result.setup = search_result.setup.replace(pattern,'$1 $4');
		}
		else{
			//search_result.setup = match[1] + match[3];
			search_results.setup = search_result.setup.replace(pattern,'$1 $3');
		}
	}
	
	return search_result;
}

var restore_percentage_and_literal_names_for_information_query = function(query){
	var inverted_literals = _.invert(numeric_literals);
	_.each(_.keys(inverted_literals),function(numeric){
		query = query.replace(numeric + "%", inverted_literals[numeric] + " percent");
		query = query.replace(numeric + " and a ", inverted_literals[numeric] + " and a ");
	});
	query = query.replace("<sup>1</sup>⁄<sup>2</sup>%","half percent");
	
	return query;
}

var replace_percentage_and_literal_numbers = function(search_result){
	_.each(_.keys(numeric_literals),function(literal){
		search_result.setup = search_result.setup.replace(literal,numeric_literals[literal]);
	});
	return search_result;
}

var replace_pattern_with_icons = function(setup){
	//console.log("setup is:");
	//console.log(setup);
	var pattern = new RegExp(/<.+?>[^<>]*?(up_?|down_?)+[^<>]*?<.+?>/)
	var match = pattern.exec(setup);

	if(!_.isNull(match)){
		//console.log("------------------------------------------------------------- GOT A MATCH");
		//console.log(match);
		
		//console.log("pattern text is:");
		//console.log(pattern_text);
		var pattern_text = match[0];
		if(pattern_text.length > 3){
			console.log("pattern text is:" );
			console.log(pattern_text);
			pattern_text = pattern_text.replace(/up/g,"<i class='material-icons'>arrow_upward</i>");
			pattern_text = pattern_text.replace(/down/g,"<i class='material-icons'>arrow_downward</i>");
			console.log("after replacing");
			console.log(pattern_text);
			setup = setup.replace(match[0],pattern_text);
			console.log("setup after replacing:");
			console.log(setup);
		}
	}
	//var up_post = new RegExp(/(up)_(up_down)/g);
	//setup = setup.replace(up_post,"<i class='material-icons'>arrow_upward</i>$2");
	//var pre_down = new RegExp(/(up|down)_(down)/g);
	//setup = setup.replace(pre_down,"$1<i class='material-icons'>arrow_downward</i>");
	//var down_post = new RegExp(/(down)_(up_down)/g);
	//setup = setup.replace(down_post,"<i class='material-icons'>arrow_downward</i>$2");
	return setup;
}

var expand_indicators_for_information_query = function(setup){
	setup = setup.replace("SOK_indicator","stochastic_oscillator_k_indicator");
	setup = setup.replace("SOD_indicator","stochastic_oscillator_d_indicator");
	setup = setup.replace("ADM_indicator","average_directional_movement_indicator");
	setup = setup.replace("DEMA_indicator","double_ema_indicator");
	setup = setup.replace("AO_indicator","awesome_oscillator_indicator");
	setup = setup.replace("TEMA_indicator","triple_ema_indicator");
	setup = setup.replace("SEMA_indicator","single_ema_indicator");
	setup = setup.replace("MACD_indicator","moving_average_convergence_divergence");
	setup = setup.replace("ACDC_indicator","acceleration_deceleration_indicator");
	setup = setup.replace("RSI_indicator","relative_strength_indicator");
	setup = setup.replace("WR_indicator","williams_r_indicator");
	return setup;
}

var shrink_indicators = function(setup){
	setup = setup.replace("stochastic_oscillator_k_indicator","SOK_indicator");
	setup = setup.replace("stochastic_oscillator_d_indicator","SOD_indicator");
	setup = setup.replace("average_directional_movement_indicator","ADM_indicator");
	setup = setup.replace("double_ema_indicator","DEMA_indicator");
	setup = setup.replace("awesome_oscillator_indicator","AO_indicator");
	setup = setup.replace("triple_ema_indicator","TEMA_indicator");
	setup = setup.replace("single_ema_indicator","SEMA_indicator");
	setup = setup.replace("moving_average_convergence_divergence","MACD_indicator");
	setup = setup.replace("acceleration_deceleration_indicator","ACDC_indicator");
	setup = setup.replace("relative_strength_indicator","RSI_indicator");
	setup = setup.replace("williams_r_indicator","WR_indicator");
	return setup;
}



// @param[String] string : the string into which the snippet is to be inserted
// @param[String] snippet : the snippet to be inserted
// @param[String] index : the index at which the snippet is to be inserted
// @return[String] string : the original string with the snippet inserted
var insert_string_at = function(string,snippet,index){
	return string.slice(0,index) + snippet + string.slice(index,string.length);
}

var add_impact_and_trade_action_to_setup = function(search_result){
	search_result.setup = search_result.trade_action_name + " " + search_result.impacts[0].entity_name + " <span class='blue-grey-text'>" + search_result.setup + "</span>";
	return search_result;
}

/***
component_data_name if null, defaults to component name.
***/
var process_setup_component = function(component,search_result,component_data_name){

	component_data_name = _.isNull(component_data_name) ? component : component_data_name;

	var component_start = search_result.setup.indexOf(component);
	if(component_start != -1){
		var component_end = search_result.setup.indexOf(component) + component.length;
		search_result.setup = insert_string_at(search_result.setup,"</span>",component_end);
		search_result.setup = insert_string_at(search_result.setup,"<span class=\"tooltip\" title=\"test\" data-name=\"" +  component_data_name  + "\">",component_start);
	}
	return search_result;
}


/**
- keeps only the first word in the entity, removes everything after and including the first underscore.
**/
var trim_entity_name = function(search_result,entity_name){
	//console.log("came to trim with entity name:" + entity_name);
	if(entity_name.indexOf("_") != -1){

		var idx = entity_name.indexOf("_");
		var part_after_underscore = entity_name.slice(idx,entity_name.length);
		var part_before_underscore = entity_name.slice(0,idx);
		search_result.setup = search_result.setup.replace(part_after_underscore,'');
		//console.log("part before underscore:");

		search_result = process_setup_component(part_before_underscore,search_result,entity_name);
	}
	return search_result;
}


var add_data_information_to_primary_entity = function(search_result){
	var entity_name = search_result.entity_name;
	if(entity_name.indexOf("_") != -1){
		var idx = entity_name.indexOf("_");
		var part_before_underscore = entity_name.slice(0,idx);
		var with_apostrophe = part_before_underscore + "'s";
		search_result = process_setup_component(with_apostrophe,search_result,entity_name);
	}
	return search_result;
}

var add_tooltips_to_setup = function(search_result){
	
	search_result = process_setup_component(search_result.indicator_name,search_result,null);

	search_result = process_setup_component(search_result.subindicator_name,search_result,null);

	search_result = trim_entity_name(search_result,search_result.impacts[0].entity_name);

	search_result = add_data_information_to_primary_entity(search_result);

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

$(document).on('click','.related_query_term',function(event){
	search_new($(this).attr("data-related-query"));
});

$(document).on('click','.chip',function(event){
	//console.log("clicked chip with category:" + $(this).attr("data-category"));
	// if its parent is the row chip.
	if($(this).hasClass("show_more_chips")){
		// so its show more.
		$(".additional_chips").show();
	}
	else if($(this).hasClass("show_less_chips")){
		$(".additional_chips").hide();
	}
	else if($(this).hasClass("show_more_query_chips")){
		$(".query_chips").slideToggle();
	}	
	else{
		if($(this).hasClass("default_sector")){
			$("#logo").slideUp('fast',function(){
				
			});
			$(".default_sectors").first().hide();
		}
		else{

		}
		search_new($(this).attr("data-category"));
	}
});

// I want a side by side comparison, in one tab only.
// with a switch to show what exactly is happening.

/****
tooltipster ajax.
****/

var quotes = {
	"Probabilities guide the decisions of the wise." : "Marcus Tullius Cicero, Roman Philosopher, 63 BC",
	"Because, there is no joy in the finite. True bliss is in the infinite" : "Chandogya Upanishad, 8 BCE",
	"There's nothing in the world so demoralizing as money" : "Sophocles, 497 BCE",
	"After a certain point, money is meaningless. It ceases to be the goal. The game is what counts" : "Aristotle Onassis, Greek Shipping Billionaire(1906 - 1975)",
	"Let your hook always be cast; in the pool where you least expect it, there will be a fish." : "Publius Ovidius Naso(Ovid), Roman Poet, 17 AD",
	"I paraphrase Lord Rothschild: ‘The time to buy is when there's blood on the streets.'" : "David Dreman  Author - Contrarian Investment Strategies: The Psychological Edge.",
	"Start a fight. Prove you're alive. If you don't claim your humanity you will become a statistic. You have been warned." : "Chuck Palahnuick - The Fight Club",
	"Remember, that you too, are a black swan" : "Nassim Nicholas Taleb, The Black Swan : The Impact of the Highly Improbable",
	"I have a 41-year track record of investing excellence… what do you have?" : "Bill Gross, Founder ~ PIMCO",
	"One should tread the sinless path and gather wealth." : "(Vajasaneya Samhita iv-9)(Vedas)",
	"The rich rules over the poor, and the borrower is the slave of the lender." : "Proverbs 22:7",
	"A man's worth is no greater than his ambitions." : "~ Marcus Aurelius, Emperor of Rome",
	"We really can't forecast all that well, and yet we pretend that we can, but we really can't." : "Alan Greenspan",
	"People who advocate simplicity have money in the bank; the money came first, not the simplicity." : "Douglas Coupland, The Gum Thief",
	"What do you mean there is no money in the bags?" : "Ocean's Eleven",
	"Misdirection, what the eyes see and the ears hear, the mind believes" : "Gabriel, Swordfish(2001)",
	"Don't *ever* risk your life for an asset. If it comes down to you or them... send flowers." : "Nathan Muir, Spy Game(2001)",
	"Man sacrifices his health in order to make money. Then he sacrifices money to recuperate his health" : "The Dalai Lama",
	"You will soon be dead, and then you will own just as much of this earth as will suffice to bury you." : "Hindu yogi, replying to Alexander the Great",
	"Greece , Rome and Persia are in Me. The suns and stars rise and set in Me." : "Indian yogi to Alexander the Great.",
	"The farther backward you can look, the farther forward you can see" : "Winston Churchill",
	"Mankind is divided into rich and poor, into property owners and exploited" : "Joseph Stalin",
	"Forethought we may have, undoubtedly, but not foresight" : "Napoleon Bonaparte",
	"The worse a situation becomes, the less it takes to turn it around." : "George Soros",
	"There's only one boss, the customer. He can fire everyone from the Chairman down, simply by spending his money somewhere else." : "Sam Walton"
}

var numeric_literals = {
	"one" : "1",
	"two" : "2",
	"three" : "3",
	"four" : "4",
	"five" : "5",
	"sixty" : "60",
	"six" : "6",
	"ten" : "10",
	"twenty" : "20",
	"thirty" : "30",
	"forty" : "40",
	"fifty" : "50",
	"seventy" : "70",
	"eighty" : "80",
	"ninety" : "90",
	"hundred" : "100",
	"half" : "<sup>1</sup>&frasl;<sup>2</sup>",
	" percent" : "%"
}

// so entity icons.
// indicator and subindicator information.
// something like more_info, for all the items.
// i can have an index, where we have the name, and we have an information box for it.
// direct entity search.
// maybe an image and an icon.
// and a link.
// and entity should have an icon attribute, basically as well, that is assigned when it is created, and transferred to it, 
// in the correlation.


$(document).ready(function(){
	var quote = _.sample(Object.keys(quotes), 1);
	var quote_author = quotes[quote];
	$("#quote").text(quote);
	$("#quote_author").text(quote_author); 
    //
    $('.tooltip').tooltipster();
});


/////////////////////////////////////////////////////////////////////////////

/***
List from : https://www.ranks.nl/stopwords
Default English Stopwords List.
****/
var stopwords = {
	"a":"1",
	"about":"1",
	"above":"1",
	"after":"1",
	"again":"1",
	"against":"1",
	"all":"1",
	"am":"1",
	"an":"1",
	"and":"1",
	"any":"1",
	"are":"1",
	"aren't":"1",
	"as":"1",
	"at":"1",
	"be":"1",
	"because":"1",
	"been":"1",
	"before":"1",
	"being":"1",
	"below":"1",
	"between":"1",
	"both":"1",
	"but":"1",
	"by":"1",
	"can't":"1",
	"cannot":"1",
	"could":"1",
	"couldn't":"1",
	"did":"1",
	"didn't":"1",
	"do":"1",
	"does":"1",
	"doesn't":"1",
	"doing":"1",
	"don't":"1",
	"down":"1",
	"during":"1",
	"each":"1",
	"few":"1",
	"for":"1",
	"from":"1",
	"further":"1",
	"had":"1",
	"hadn't":"1",
	"has":"1",
	"hasn't":"1",
	"have":"1",
	"haven't":"1",
	"having":"1",
	"he":"1",
	"he'd":"1",
	"he'll":"1",
	"he's":"1",
	"her":"1",
	"here":"1",
	"here's":"1",
	"hers":"1",
	"herself":"1",
	"him":"1",
	"himself":"1",
	"his":"1",
	"how":"1",
	"how's":"1",
	"i":"1",
	"i'd":"1",
	"i'll":"1",
	"i'm":"1",
	"i've":"1",
	"if":"1",
	"in":"1",
	"into":"1",
	"is":"1",
	"isn't":"1",
	"it":"1",
	"it's":"1",
	"its":"1",
	"itself":"1",
	"let's":"1",
	"me":"1",
	"more":"1",
	"most":"1",
	"mustn't":"1",
	"my":"1",
	"myself":"1",
	"no":"1",
	"nor":"1",
	"not":"1",
	"of":"1",
	"off":"1",
	"on":"1",
	"once":"1",
	"only":"1",
	"or":"1",
	"other":"1",
	"ought":"1",
	"our":"1",
	"ours	ourselves":"1",
	"out":"1",
	"over":"1",
	"own":"1",
	"same":"1",
	"shan't":"1",
	"she":"1",
	"she'd":"1",
	"she'll":"1",
	"she's":"1",
	"should":"1",
	"shouldn't":"1",
	"so":"1",
	"some":"1",
	"such":"1",
	"than":"1",
	"that":"1",
	"that's":"1",
	"the":"1",
	"their":"1",
	"theirs":"1",
	"them":"1",
	"themselves":"1",
	"then":"1",
	"there":"1",
	"there's":"1",
	"these":"1",
	"they":"1",
	"they'd":"1",
	"they'll":"1",
	"they're":"1",
	"they've":"1",
	"this":"1",
	"those":"1",
	"through":"1",
	"to":"1",
	"too":"1",
	"under":"1",
	"until":"1",
	"up":"1",
	"very":"1",
	"was":"1",
	"wasn't":"1",
	"we":"1",
	"we'd":"1",
	"we'll":"1",
	"we're":"1",
	"we've":"1",
	"were":"1",
	"weren't":"1",
	"what":"1",
	"what's":"1",
	"when":"1",
	"when's":"1",
	"where":"1",
	"where's":"1",
	"which":"1",
	"while":"1",
	"who":"1",
	"who's":"1",
	"whom":"1",
	"why":"1",
	"why's":"1",
	"with":"1",
	"won't":"1",
	"would":"1",
	"wouldn't":"1",
	"you":"1",
	"you'd":"1",
	"you'll":"1",
	"you're":"1",
	"you've":"1",
	"your":"1",
	"yours":"1",
	"yourself":"1",
	"yourselves":"1"
}