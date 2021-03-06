//= require jquery_ujs 
//= require search.js
//= require utils.js
//= require logs.js
//= require result.js
//= require cloudinary
//= require images.js
//= require pretty_images.js
//= require search_result_chart.js
//= require autocomplete_patch.js
//= require stock.js
//= require our_story.js
//= require entity_logs.js
//= require session_logs.js
//= require exchange_logs.js

// can we call setup ?
// setup some dummy patients ?
// and confirm them
// then we can start testing out order creation.
// now for infinite scroll, with tabs.
/****
DISCLAIMER : I don't know ratshit about Javascript. This file, summarizes my knowledge of the subject.
*****/

// so we need to just show the max possible profit and loss for 
// the week in the template.
// so basically modify the template
// use the week display technique.


// remove **Indian Stocks**
// remove 

_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};


_.templateSettings.variable = 'search_result'; 

var template;



var slide_down_logo = function(event){
	$("#logo").slideDown('fast',function(){
		//$('#autocomplete-input').removeClass("input-mobile");
		$('#new_search_results').hide();
		$('.show_more_query_chips').remove();
		$('.query_chips').remove();
		$('.related_chips').remove();
		//$('.default_sectors').first().show();
		$("#related_queries_holder").empty();
		$("#related_queries_title").hide();
		$("#exchanges").show();
		$(".tip").show();
		$("#input-clear").removeClass("input-clear");
		$("#input-clear").hide();
		if(is_mobile() == true){
			$("#autocomplete-input").parents(".container").first().removeClass("container-mobile");
			$("#autocomplete-input").removeClass("input-mobile");
			$("#autocomplete-input").prev().removeClass("input-prefix-mobile");
			show_navbar();
		}
		$("label[for='autocomplete-input']").removeClass("active");
	});
}


$(document).on('click','.dedication',function(event){
	$(".dedication-text").first().slideToggle();
})
/***
clear the search bar if the clear icon is clicked.
***/
$(document).on('click','#input-clear',function(event){
	$("#autocomplete-input").val("");
	slide_down_logo();
});

// write a listener for the screen size.

// first lets get this shit to display at least.
$(document).on('input','#autocomplete-input',function(event){
	////////////console.log("keydown triggered" + event.keyCode);
	if(event.keyCode == 32){
		var autocomplete_hash = JSON.parse($(".autocomplete").first().data('autocomplete_hash'));

		//$('.autocomplete').autocomplete('updateData',_.object(_.map(autocomplete_hash,function(value,key){return [key,null];})));
		//////console.log("autocomplete hash:");
		//////console.log(autocomplete_hash);
		$('.autocomplete').autocomplete('updateData',autocomplete_hash);
	}
	else{
		//////////console.log("the val is:" + $(this).val());
		search_action($(this).val());
	}
});	

// that fucking hash has the div id.
// so it tries to load that
// if that is null, how to know /

$(document).on('keydown','#search',function(event){
	search_action($(this).val());
});

var is_mobile = function(){
	var small_screen = window.matchMedia('(max-width: 600px)').matches;
	return small_screen;
}

var hide_navbar = function(){
	//console.log("came to hide navbar");
	var small_screen = window.matchMedia('(max-width: 600px)').matches;
	//console.log("Small screen: " + String(small_screen));
	if(small_screen == true){
		//console.log("it is true");
		$("#navbar").hide();
	}
}

var show_navbar = function(){
	$("#navbar").show();
}

$(document).on('focus','#autocomplete-input',function(event){
	$("#logo,#exchanges").slideUp('fast',function(){
						
	});
	$(".default_sectors").first().hide();
	$(".tip").hide();
	
	$("#input-clear").addClass("input-clear");
	$("#input-clear").show();
	if(is_mobile() == true){
		$(this).parents(".container").first().addClass("container-mobile");
		$(this).addClass("input-mobile");
		$(this).prev().addClass("input-prefix-mobile");
		hide_navbar();
	}
	clear_page_content();
});

var clear_page_content = function(){
	$("#page_content").html("");
}

$(document).on('focusout','#autocomplete-input',function(event){

	
		if(!$(event.relatedTarget).hasClass("autocomplete-content")){
			if(($("#new_search_results").find(".search_result_card").length) == 0){

				////console.log("length is:" + $("#new_search_results").find(".search_result_card").length);
				////console.log(_.isEmpty($("#new_search_results").find(".search_result_card").length));
				slide_down_logo();
				//$("#logo,#exchanges").slideDown('fast',function(){
				
				//});
			}
		}
	
});

var search_action = function(input){
	////////////console.log("triggered search action");
	////////////console.log("input is: " + input);
	//if(event.keyCode == 32){
		//////////////console.log("got space, doing nothing.");
	//}
	//else{
		if( !input ) {
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
			search_new(input);
		}
	//}
}


var search_result_is_positive = function(search_result){
	
	return search_result.impacts[0].statistics[0].gold_coins >= search_result.impacts[0].statistics[0].other_coins;
	
	// sort out the space issues and other such bullshit
	// why is it failing on space.
	// and not searching anything else afterwards
	//////////////console.log("----------- statistics ----------------");
	//////////////console.log(search_result.impacts[0].statistics[0]);
	//return search_result.impacts[0].statistics[0].maximum_profit >= search_result.impacts[0].statistics[0].maximum_loss*-1
}

// so after rendering, we show the populating indicators.
var show_indicator_description = function(search_result){
	// this is an ajax request.
}

var show_primary_entity_description = function(search_result){

}

var show_impacted_entity_description = function(search_result){

}

$(document).on('click','.refresh_trend',function(event){
	// we cycle forwards.
	var trends = JSON.parse($("#front_page_trend").attr("data-trends"));
	var trend = _.sample(trends);
	$("#front_page_trend_setup").text(trend["setup"] + "(" + trend["dateString"] + ")");
	var icon_text = null;
	var icon_color = null;
	if(trend["trend_direction"] == "rise"){
		icon_text = "trending_up";
		icon_color = "green";
	}
	else if(trend["trend_direction"] == "fall"){
		icon_text = "trending_down";
		icon_color = "red";
	}
	$("#front_page_trend_setup").prev().attr("class","material-icons " + icon_color + "-text");
	$("#front_page_trend_setup").prev().text(icon_text);
});



var build_chart_dataset = function(serach_result){

}
	
// what would be the right thing to do ?
// to paginate this stuff.
// get it postable to facebook and twitter at the least.
// and shareable on everything else.
// 

var render_search_result_new = function(search_result){
	if(_.isUndefined(template)){
		////console.log("got a template");
		var template = _.template($('#search_result_template').html());
	}
	// there is something called none.
	// first modify the search result template
	// give it space for the indicator description, 
	$('#none').append(template(search_result));
	// knock of last_couple of years
	// sharing it will be a different thing.
	// we need a query style url thing.
	// otherwise we are screwed.
	// query style -> js erb -> with an index showing the result.
	// something like that.
	// which they can search and get.
	// query string we can try today only.
	// we need endpoints for R-E-xyz/E-n -> this gives only one search result -> and is displayed, with all the twitter card metadata, and all the share buttons.
	// then we need endpoints like 
	// query string -> for search
	// all the way down to these hierarchies
	// exchange/entity/indicator/subindicator

	draw_chart(("search_result_chart_" + search_result.div_id),search_result);
	/****
	if(search_result_is_positive(search_result)){
		//////////////console.log(template(search_result));
		$('#positive').append(template(search_result));
	}
	else{
		$('#negative').append(template(search_result));
	}
	****/
	$("time.timeago").timeago();
}

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

// okay so now the tube imaging, for hemolysis is next.
// and then we go back to interfacing.

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
	information_title = information_title.replace(/close/,'');
	return humanize(information_title);
}

/// we can go with query strings ?
/// results controller  results/:rid?entity_id=E-22
/// this is to deep link to search_results > for twitter etc.
/// making the svg a jpg.

/// indicators controller indicators/stochastic_oscillator_k_indicator?id=1-10 -> should show the information on stochastic, and 10 search results with that indicator, that will just be a query string.

/// exchanges controller exchanges/:exchange_name -> should show the details of that exchange and 10 search results.

/// indicators
/// subindicators
/// exchanges
/// entities
/// exchanges/exchange_id/entities/entity_id/indicators/indicator_id/subindicators/subindicator_id
/// we will need MVC, For all of them, to be able to render views.
/// with breadcrumbing.
/// query string like : ?
/// linking to a direct result id.

var humanize_tags = function(tags){
	// so we join the tags and see if we can return somdthing sensible,
	// otherwise go with the default.
	// that's going to have to be a specific type of query.
	// fall
	var tag_line = tags.join(" ");
	var close_pattern = new RegExp(/close_period_start_\d+_period_end\s(falls|rises)/);
	if(close_pattern.test(tag_line) == true){
		// replace that
		// no need for see more.
		// what happens to us stocks when indian stocks fall(by 2%)
		// we are only interested in week.
		// so any percentage in a week.
		// 
	}
	else{

	}

}


var get_primary_entity_and_indicator = function(search_result){
	var setup = search_result.setup;
	console.log("setup is:" + setup);
	var pattern = new RegExp(/when([A-Za-z\s0-9\-\_]+)\'s\s([A-Za-z_\d+]+)\s(indicator)?/gi);
	var result = pattern.exec(setup);
	if(!_.isNull(result)){
		search_result.primary_entity = result[1];
		search_result.indicator = result[2].replace(/_period_start_\d+_period_end/,'');
		if(!_.isUndefined(result[3])){
			search_result.indicator += (" " + result[3])
		}
	}

	
	console.log("search result primary entity:" + search_result.primary_entity + " indicator: " + search_result.indicator);
}

// one problem at a time.
// called after build setup.
var build_meta_description = function(search_result){
	search_result.description = "Historically " + search_result.target + search_result.rises_or_falls + " " + search_result.percentage + "%" +  " of the times.";
};

var add_chart_image_url = function(search_result){
	search_result.chart_url = "";
};

var add_twitter_cards_details = function(search_result){

};

var build_setup = function(search_result,text){

	// see the tags have to be assembled
	// i dont' know what the fuck your're doing with this.


	var complex_string = search_result.preposition + " ";
	
	var time_subindicator_regexp = new RegExp(/first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/g);

	// first test the tags to see if they contain period_start_period_end.
	// then that is not a time based subindciator.
	var non_time_subindicator = new RegExp(/period_start_\d/g)

	// this has to be done better.
	// if the part inside the ** contains the text
	// then we keep it and knock off the other part.
	// this is not going to be easy.
	// same thing is repeated below in the final else.
	//console.log("search result is:");
	//console.log(search_result);
	if(non_time_subindicator.test(search_result.tags) == true){
		
		//////////console.log("Tags are");
		//////////console.log(search_result.tags);
		var prev_tag_is_colloquial = 0
		_.map(search_result.tags,function(tag,index){

			// okay so handle colloquial seperator here.
			if(tag.startsWith("**")){
				//////////console.log("starts with double star:" + tag);
				// this is the colloquial, ignore it.
				if(!tag.endsWith("**")){
					//////////console.log("endswith double star");
				 prev_tag_is_colloquial = 1;
				}
			}
			else if(tag.endsWith("**")){
				//////////console.log("directy ends with double star" + tag);
				prev_tag_is_colloquial = 0;
			}
			else if(tag.startsWith("**") && tag.endsWith("**")){
				//////////console.log("starts and ends with:" + tag);
			}
			else{
				if(prev_tag_is_colloquial == 0){
					//////////console.log("neither starts with and neither ends with double star ad goes forward" + tag);
					if(index == 0){
						complex_string =  complex_string + tag + "'s" + " "  ;
					}
					/****
					else if(index == 2){
						complex_string = complex_string + tag + " " + "See-More ";
					}
					***/
					else{
						complex_string = complex_string + tag + " ";
					}
				}
			}
		});
		complex_string = complex_string 

	}
	else{

		//puts "Came to the else"
		if(time_subindicator_regexp.test(search_result.information) == true){
			//puts "information hit "
			//////////console.log("information test worked.");
			//////////console.log(search_result.tags);
			// if any of the tags have 
			// period_start_period_end
			// then
			var prev_tag_is_colloquial = 0
 
			_.map(search_result.tags,function(tag,index){
				
				if(tag.startsWith("**")){
					//////////console.log("starts with double star:" + tag);
					// this is the colloquial, ignore it.
					if(!tag.endsWith("**")){
						//////////console.log("endswith double star");
					 prev_tag_is_colloquial = 1;
					}
				}
				else if(tag.endsWith("**")){
					//////////console.log("directy ends with double star" + tag);
					prev_tag_is_colloquial = 0;
				}
				else if(tag.startsWith("**") && tag.endsWith("**")){
					//////////console.log("starts and ends with:" + tag);
				}
				else{
					if(prev_tag_is_colloquial == 0){
						complex_string = complex_string + tag + " ";
					}
				}
			
			});

		}
		else if(time_subindicator_regexp.test(search_result.tags) == true){


			//////////console.log("got a time based subindicator, by checking the tags");
			_.map(search_result.tags,function(tag,index){
			
				if(tag.startsWith("**") && tag.endsWith("**")){

				}
				else{

					complex_string = complex_string + tag + " ";
				}
			
			});
			// gotta debug this
			// next step would be to make it easier to read.
			// up_down patter html.
			// 
		}		
		else
		{
			// non time subindicator.
			//////////console.log("tags are");
			//////////console.log(tags);
			_.map(search_result.tags,function(tag,index){

				if(tag.startsWith("**")){
				// this is the colloquial, ignore it.
				 	if(!tag.endsWith("**")){
				 		prev_tag_is_colloquial = 1;
				 	}
				}
				else if(tag.endsWith("**")){
					prev_tag_is_colloquial = 0;
				}
				else if(tag.startsWith("**") && tag.endsWith("**")){

				}
				else{
					if(prev_tag_is_colloquial == 0){
						if(index == 0){
							// full name.
							complex_string =  complex_string + tag + "'s" + " ";
						}
						else if(index == 1){
							// symbol

						}
						/***
						else if(index == 2){
							complex_string = complex_string + "See-More ";
						}
						***/
						else{
							complex_string = complex_string + tag + " ";
						}
					}
				}
			});	

			complex_string = complex_string 		
		}

	}

	////// so it ignores that.
	//////////////console.log("complex string becomes:");
	//////////////console.log(complex_string);
	// so if it comes with hyphens after the preposition and 
	// that preposition is when, then we get rid of those hyphens.
	// the problem is for the rollovers.

	search_result.setup = search_result.setup + " " + complex_string;	
	search_result.complex_string = complex_string;
	assign_target(search_result);
	get_primary_entity_and_indicator(search_result);
	//////////console.log(search_result);
	//remove_close(search_result);

	// indicator rises by 90 percent in 10 days.
	// so we just shortened it to changes.
	// can we hide this in some way ?
	// so i don't want to do this part at the moment.

	/****
	var parts = search_result.setup.split(/indicator/);
	if(_.size(parts) > 1){
		search_result.setup = parts[0] + "indicator" + " changes";

	}	
	var rises_parts = search_result.setup.split(/(rises|falls)/);
	//////////////console.log("rises parts are:");
	//////////////console.log(rises_parts);	
	// for rises falls and crosses.
	if(_.size(rises_parts) > 1){
		search_result.setup = rises_parts[0] + rises_parts[1]; 
	}
	***/
	add_chart_image_url(search_result);
}

// so on clicking choose report, it executes an update
// adds a hidden report id, and executes the update
// inside order, it first matches and loads those report ids
// so let me do that first.
// then will show those reports



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
	//////////////console.log("stats are:");
	//////////////console.log(stats);
	var categories = stats.slice(12,stats.length);
	search_result.categories = categories;
	//////////////console.log("the search result categories are:");
	//////////////console.log(search_result.categories);
}

var set_related_queries_from_suggestion_input = function(search_result,related_queries){
	search_result.related_queries = related_queries.split(",");
}

/***
***/
var set_origin_categories = function(search_result){
	// this and also where to display them.
}

// @return[Array]:
// primary entity is at index 0,1
// secondary entity is at index 2,3
// length : , offset, length, offset
var get_offsets = function(input_text){
	var result_object = {};
	var split_on_offsets = input_text.split("*");
	text_stats_and_related_queries = split_on_offsets[0];
	offsets = split_on_offsets[1];
	return offsets.split(",");
}


var get_rises_or_falls = function(statistic){
	if (statistic.total_up >= statistic.total_down){
		return "tends to rise";
	} 
	else{
		return "tends to fall";
	}
}


var get_percentage = function(statistic){
	if(statistic.total_up >= statistic.total_down){
		return Math.round((statistic.total_up/(statistic.total_up + statistic.total_down))*100);
	}
	else{
		return Math.round((statistic.total_down/(statistic.total_up + statistic.total_down))*100);
	}
}

/***
@param[Array] stats
@param[Object] search_result
***/
var set_year_wise_data = function(stats,search_result){
	////////console.log("stats are:");
	////////console.log(stats);
	var year_wise_data = {}
	var year_wise_data_string = stats[0].split("$$")[1];
	var prev_key = null;
	//////console.log("year wise data string is:");
	//////console.log(year_wise_data_string);
	var parts = year_wise_data_string.split("$");

	var max_rise_fall_data = parts.slice(Math.max(parts.length - 6, 0));
	
	var yw_data = parts.slice(0,(parts.length - 6));
	//var yw_data = parts.slice(Math.max(parts.length - 6, 0));


	//////console.log("max rise fall data:");
	//////console.log(max_rise_fall_data);

	////console.log("yw data is;");
	////console.log(yw_data);

	search_result.maximum_rise_year = max_rise_fall_data[0];
	search_result.maximum_rise_month = max_rise_fall_data[1];
	search_result.maximum_rise_amount = (Number(max_rise_fall_data[2]))/10;

	search_result.maximum_fall_year = max_rise_fall_data[3];
	search_result.maximum_fall_month = max_rise_fall_data[4];
	search_result.maximum_fall_amount = (Number(max_rise_fall_data[5]))/10;

	_.each(yw_data,function(val,key){
		if(key % 3 == 0){
			year_wise_data[val] = [];
			prev_key = val;
		}
		else{
			if(!_.isNull(prev_key)){
				year_wise_data[prev_key].push(val);
			}
		}
	});
	search_result.year_wise_data = year_wise_data;
	stats[0] = stats[0].split("$$")[0];
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
	
	////console.log(search_result);

	var offsets = get_offsets(search_result.suggest[0].input);
	var suggestion = search_result.suggest[0];
	////console.log("suggestion");
	////console.log(suggestion);
	////console.log("suggestion input is:");
	////console.log(suggestion.input);
	var related_queries = suggestion.input.split("%")[1].split("*")[0];
	var pre = suggestion.input.split("%")[0];
	var information = pre.split("#");

	
	search_result.information = information;
	//////////////console.log("information is:");
	//////////////console.log(information);

	var stats = information[1];

	stats = stats.split(",");
	////////console.log("stats are:");
	////////console.log(stats);
	// so we are using offsets here.
	// this picks the target
	// basically using these offsets
	// so why are sometimes 
	// and that is not a part of the tags anyways.
	// the tags can have the stars
	// my problem is that 
	search_result.setup = "What happens to " + information[0].substring(offsets[0],offsets[1]);

	// remove hyphens from the namess. like Indian-Stocks
	search_result.setup = search_result.setup.replace(/\-/," ");

	//so here we want to 

	// so its splitting on the space.

	search_result.triggered_at = search_result.epoch;

	// this sets the 
	set_impacted_categories_from_suggestion_input(search_result,stats);
	set_related_queries_from_suggestion_input(search_result,related_queries);
	////console.log("stats before slice");
	////console.log(stats);
	stats = stats.slice(0,12);
	
	////console.log("stats before going in:");
	////console.log(stats);
	set_year_wise_data(stats,search_result)

	build_setup(search_result,text);

	search_result.impacts = [];

	var impact = {
		statistics: []
	}

	/////console.log("setup is:");
	//////console.log(search_result.setup);
	////console.log("stats are:");
	////console.log(stats);
	//////console.log("-----------------------");

	/// add week.
	if((Number(stats[0]) == 0) && (Number(stats[1]) == 0)){

	}
	else{
		impact.statistics.push({
			time_frame: 1,
			time_frame_unit: "days",
			time_frame_name: "1 day",
			total_up: Number(stats[0]),
			total_down: Number(stats[1]),
			maximum_profit: Number(stats[2]),
			maximum_loss: Number(stats[3])
		})
		search_result.rises_or_falls = get_rises_or_falls(impact.statistics[0]);
		search_result.percentage = get_percentage(impact.statistics[0]);
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
		//////////////console.log("making query from indicator");
		//////////////console.log("new query:");
		//////////////console.log(expand_indicators_for_information_query(origin.data("name")));
		query = expand_indicators_for_information_query(origin.data("name")).replace(/_period_start_\d+_(\d+_)*period_end/,"");
		//////////////console.log("query is:");
		//////////////console.log(query);
	}
	else{
		origin.prevAll().each(function(key,el){
			//////////////console.log("doing prevall");
			//////////////console.log(el);
			//////////////console.log($(el).data("name"));
			data_name = $(el).data("name");
			if(!_.isUndefined(data_name)){
				if(word_is_indicator(data_name.toString())){

					if(_.isNull(indicator_element)){
						indicator_element = el;
						//////////////console.log("making query from indicator element");
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


		//////////////console.log("subindicator name contains:");
		//////////////console.log(subindicator_name);

		if(!_.isNull(indicator_element)){
			//////////////console.log("there is an indicator name");
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

// empty div should not be shown.
// 

/***
had to run this twice with regexes k1, k2, because sometimes we have a string like
what happens to adani ports when nifty 50 falls by 10% in 2 weeks.
so there is 'when' and 'in'
so the first regex keeps the part upto 'in', and the second regex then gets the actual thing.
***/
var assign_target = function(search_result){
	var k = new RegExp(/to\s([a-zA-Z0-9\s\-\_]+)\b(in|when|on)\b/);
	var k2 = new RegExp(/([a-zA-Z0-9\s\-\_]+)\b(in|when|on)\b/);
	////console.log("setup is:" + search_result.setup);
	var target = k.exec(search_result.setup);
	//console.log("target is:");
	//console.log(target);
	if(_.size(target) >= 1){
		var target_2 = k2.exec(target[1]);
		//console.log("target 2 is:");
		//console.log(target_2);
		if(_.size(target_2) >= 1){
			search_result.target = target_2[1];
		}
		else{
			search_result.target = target[1];
		}
	}
	console.log("target is:" + search_result.target);
}


var clear_html = function(){
	$("#none").html("");
	$("#positive").html('<div style="visibility:hidden">doggy</div>');
	$("#negative").html('<div style="visibility:hidden">doggy</div>');
	$("#new_search_results").show();
}


$(document).on('click','.see-more',function(event){
	////////////console.log("clicked see more");
	$(".tooltip").show();
})
// now let me solve the colloquial issue.
// 

var update_positive_and_negative_tab_titles = function(positive,negative){
	$("#positive_count").text(positive);
	$("#negative_count").text(negative);
}


function CreateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

var camelize = function camelize(str) {
  return str.replace(/\W+(.)/g, function(match, chr)
   {
        return chr.toUpperCase();
    });
}

// get twitter working, 
// and then facebook.
// first download those images.?
var compose_twitter_url = function(search_result){
	var base = "https://twitter.com/intent/tweet";
	var hashtags = [_.map(search_result.target.split(" "),function(target){
		return camelize(target);
	}).join("")];
	//var hashtags = [search_result.target];
	var text = $("<div>").html(search_result.setup).text();
	var url = search_result.url;
	// okay so this can be done.
	return base + "?url=" + encodeURIComponent(url) + "&text=" + encodeURIComponent(text) + "&hashtags=" + encodeURIComponent(hashtags.join(","));
	//return base + encodeURIComponent("?text=" + text + "&url=" + url + "&hastags=" + hashtags.join(",")); 
}

// we should use that as the catch text.
// now generate those ones'

/***
// now we need the id.
// from where do i get that.
@called_from : prepare_search_result.
***/
var set_social_sharing_urls = function(search_result){
	
	// then debug this one, last thing, and we are through and check the image also.
	console.log("the search results setup is:");
	console.log(search_result.setup);
	console.log("search result description is:");
	console.log(search_result.description);
	search_result.social_text = search_result.setup + "? " + search_result.description;

	search_result.url = "https://www.algorini.com/results/" + search_result.id + "?eid=" + search_result.impacted_entity_id;

	//search_result.url = "https://www.google.com";

	/***
	TWITTER
	****/	
	search_result.twitter_url = compose_twitter_url(search_result);


	/***
	FACEBOOK
	***/
	search_result.facebook_url = search_result.url;


	/****
	WATSAPP
	****/
	var watsapp_text = search_result.social_text + " See Chart at :" + search_result.url;
	watsapp_text = $("<div>").html(watsapp_text).text();
	search_result.watsapp_url = "https://api.whatsapp.com/send?text=" + encodeURIComponent(watsapp_text);

}

// add the links.
// and do the time resolution.
// to make it look better.
// why cac and cac 40 ?
// why not french stocks are coming -> gotta investigate all this.
var update_entity_links = function(search_result,entity_links){


	console.log("came to updat entity links");
	var entry = null;
	console.log("searh rsult inside update entity links");
	console.log(search_result);
	console.log("entity links are:");
	console.log(entity_links)

	if(search_result.primary_entity){
		entry = ("All Indicators for " + search_result.primary_entity.trim()).trim();

		if(entity_links[entry])
		{
			entity_links[entry]['score'] += 1	
		} 
		else{
			// i think it is getting stripped at some level.
			entity_links[entry] = {
				score : 1,
				lin :  ('/stocks/' + encodeURI(search_result.primary_entity.trim()))
			}		
		}
	}
	if(search_result.target){
		entry = ("All Indicators for " + search_result.target.trim()).trim();
		console.log("entry is");
		console.log(entry);
		if(entity_links[entry])
		{
			entity_links[entry]['score'] += 1	
		} 
		else{
			entity_links[entry] = {
				score : 1,
				lin :  ('/stocks/' + encodeURI(search_result.target.trim()))
			}	
		}
	}

	// sitemap logging, positive negative indicator issue
	// exchange summary, filter timing, market stack.

	if(search_result.primary_entity && search_result.target){
		entry = ("How " + search_result.primary_entity.trim() + " affects " + search_result.target.trim()).trim();


		if(entity_links[entry])
		{
			entity_links[entry] += 1	
		} 
		else{
			entity_links[entry] = {
				"score" : 1,
				"link" : ("stocks/" + search_result.target.trim() + "/with_stock/"+ search_result.primary_entity.trim())
			}	
		}
	}

	// now test this much

	console.log("entity links after inital adding");
	console.log(entity_links);

}

var prepare_search_result = function(search_result,autocomplete_suggestions_hash,total_positive,total_negative,categories,related_queries,entity_links){

	////console.log(search_result['_id']);

	////console.log("------------------------");
	
	text = search_result["text"];
	id = search_result["_id"];
	search_result = search_result['_source'];
	search_result.id = id;
	assign_statistics(search_result,text);
	search_result = update_coin_counts(search_result);
	search_result = update_bar_lengths(search_result);
	search_result = convert_n_day_change_to_superscript(search_result);
	search_result = replace_percentage_and_literal_numbers(search_result);
	search_result.setup = shrink_indicators(search_result.setup);
	search_result = strip_period(search_result);
	search_result = update_falls_or_rises_text(search_result);	
	search_result = add_time_to_setup(search_result);
	// okay so what next.
	// do we knock off the dates ?
	// what about the dots ?
	// let me sort out search.
	search_result.div_id = CreateUUID();
	search_result = get_statistical_summary(search_result);
	// knock of years without any kind of data.
	// 

	build_time_based_indicator_summary(search_result);
	build_meta_description(search_result);

	search_result.summary_style = "";
	
	if(_.isNull(search_result.summary) || _.isEmpty(search_result.summary.trim()) || _.isUndefined(search_result.summary)){
		search_result.summary_style = "display:none;"
	}
	
	// sodwa

	autocomplete_suggestions_hash[search_result.setup.replace(/<\/?[^>]+(>|$)/g, "").replace(/See-More/g,"")] = {div_id : search_result.div_id
	};

	// knock off see-more
	// and add the arrows and superscript after the highlight.


	var arr = search_result.setup.split(" ");
	var concat = "";
	var see_more_triggered = false;
	_.each(arr,function(value,index){
		if(value == "See-More"){
			see_more_triggered = true;
			////////////console.log("see more is triggered");
			concat += "<span class='see-more'>...</span>";
		}
		else{
    		if(index == 2){
    			var cls = 'blue-grey-text';
    			var style = 'display:inline;';
    			if(see_more_triggered === true){
    				style = 'display:none;';
    			}
    			concat+= ("<span style=" + style + " class=" + cls + ">"+ "<span class='tooltip' title='" + value + "' data-name='" + value +"'> " + replace_pattern_with_icons(value) + "</span>");
    		}
    		else{
    			var cls = 'tooltip';
    			var style = 'display:inline;';
    			if(see_more_triggered === true){
    				style = 'display:none;';
    			}
    			////////////console.log("style is:" + style);
    			concat+= ("<span style=" + style + " class=" + cls + " title='" + value + "' data-name='" + value +"'> " + replace_pattern_with_icons(value) + "</span>");
    		}
		}

	});
	concat += "</span>";
	var icon = get_icon(search_result.setup);
	search_result.setup = icon + concat;	
	
	categories = _.union(search_result.categories,categories);
	related_queries = _.union(search_result.related_queries,related_queries);
	if(search_result_is_positive(search_result)){
		++total_positive;
	}
	else{
		++total_negative;
	}
	set_social_sharing_urls(search_result);
	update_entity_links(search_result,entity_links);
	return search_result;
}

// id like to do this and more.
// we fold the indicators, add it into a seperate data elemet.
// it renders the javascript with the content
/****
@return[Hash]
## key => search result text
## value => id of holder div
## this hash is meant to populate the autocomplete suggestions.
## clicking on one of them -> should show that particular div.
## they are all hidden by default.
****/
var display_search_results = function(search_results,input){
	var autocomplete_suggestions_hash = {}
	clear_html();
	$('.tabs').tabs();
	$('#search_results').html("");
	$('#categories').html("");
	// we need to pipe the exact entity category name also babo.
	var categories = [];
	var related_queries = [];
	var total_positive = 0;
	var total_negative = 0;
	// and later use a template to get this.
	// we have primary entity, and we have target
	// so we can show the top primary entity -> target pair
	// and 
	// and show that here directly with the links, as last 2.
	// lets get this working.
	var entity_links = {};
	search_results = _.map(search_results,function(search_result,index,list){
	    	search_result = prepare_search_result(search_result,autocomplete_suggestions_hash,total_positive,total_negative,categories,related_queries,entity_links);
	    	
	    	// what about the pair.
	    	console.log("search result becomes:");
	    	console.log(search_result);
	    	render_search_result_new(search_result);
	    	return search_result;
    });

	console.log("entity links are:");
	console.log(entity_links);
	// so we can do this.
	var top_n_links = {};

	_.each(Object.keys(entity_links),function(key,index,list){
		if(index <= 2){
			top_n_links[key] = entity_links[key];
		}	
	});
	
	$.extend(autocomplete_suggestions_hash,top_n_links);

	// so show me a way to directly get those
	// trim both sides.

    update_positive_and_negative_tab_titles(total_positive,total_negative);

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

	            	//////////////console.log("data is:");
	            	//////////////console.log(data);
	            	if(!_.isEmpty(data["results"])){

	            		result = data["results"][0]["_source"];
	            		////////////console.log("result is:" + result);

		            	title_string = "<h5 class='white-text'>"+ prepare_information_title(result["information_name"]) +"</h5><br>";

		            	content_string = result["information_description"] + "<br>";

		            	link_string = '';

		            	if(!_.isEmpty(result["information_link"])){
		            		//////////////console.log("there is an information link");
		            		link_string = "<a href=\"" + result["information_link"] + "\">Read More</a>";
		            	}
		            	
		            	var content = title_string + content_string + link_string

		            	//////////////console.log("content" + content);

		                instance.content(content);
		               
		                $origin.data('loaded', true);

	            	}
	            	
	            });
	        }
	    }
	});
	////////////console.log("categories are:");
	////////////console.log(categories);
	////////////console.log("related queries are:");
	////////////console.log(related_queries);
	var k = _.union(categories,related_queries);	
	render_categories(k);
	var results = {};
	results["autocomplete_suggestions_hash"] = autocomplete_suggestions_hash;
	results["search_results"] = search_results;
	return results;
}

var query_pending = function(input){
	var already_running_query = $("#already_running_query").attr("data-already-running-query");
	//////////////console.log("already running query is:");
	//////////////console.log(already_running_query);
	if(!_.isEmpty(already_running_query)){
		$("#queued_query").attr("data-queued-query",input);
		return true;
	}
	else{	
		return false;
	}
}



var search_new = function(input){
	//////////console.log("came to search new with input: " + input);
	if(query_pending(input) == true){
		//////////console.log("cant process input:" + input);
		//////////console.log("a query is pending");	
	} 
	else{
		//////////////console.log("no pending query");
		var ajaxTime = new Date().getTime();
		$.ajax({
		  	url: "/search",
		  	type: "GET",
		  	dataType: "json",
		  	data:{query: input},
		  	beforeSend: function(){
		  	  
		  	  $("#progress_bar").css("visibility","visible");
		      $("#already_running_query").attr("data-already-running-query",input);
		    }, 
		  	success: function(response,status,jqxhr){
		  		//////////console.log(jqxhr);
		  		var totalTime = new Date().getTime()-ajaxTime;

		  		//////////////console.log("server side took:" + totalTime);

		    	$('#search_results').html("");
		    	
		    	var search_results = response['results']['search_results'];
		    	if(_.isEmpty(search_results)){
		    		$("#related_queries_title").hide();
		    	}
		    	else{
		    		var autocomplete_hash = display_search_results(search_results,input)["autocomplete_suggestions_hash"];
		    			
		    		$(".autocomplete").first().data('autocomplete_hash',JSON.stringify(_.object(_.map(autocomplete_hash,function(value,key){return [key.replace(/<\/?[^>]+(>|$)/g, "").trim(),value];}))));



		    		//$('.autocomplete').autocomplete('updateData',_.object(_.map(autocomplete_hash,function(value,key){return [key,null];})));
		    		console.log("autocomplete hash is:");
		    		console.log(autocomplete_hash);
		    		$('.autocomplete').autocomplete('updateData',autocomplete_hash);
		    		//////////console.log("updated the autocomplete");
		    		$(".chip").each(function(index){
						if($(this).data("clicked") == "yes"){
							$(this).data("clicked","no");
							$(".search_result_card").first().show();
						}
					});	

		    	}
			},
			complete: function(){
				$("#progress_bar").css("visibility","hidden");
				$("#already_running_query").attr("data-already-running-query","");
				//////////////console.log("unsetting already running query");
				//////////////console.log($("#queued_query").attr("data-queued-query"));

				if(!_.isEmpty($("#queued_query").attr("data-queued-query"))){
					//////////////console.log("firing search request again for queued query.");
					//////////console.log("qud query is:");
					//////////console.log($("#queued_query").attr("data-queued-query"));
					var queued_query = $("#queued_query").attr("data-queued-query");
					$("#queued_query").attr("data-queued-query","");
					console.log("going to search new with queued query------------");
					search_new(queued_query);
				}
			}
		});
	}
}



$(document).on('click','li',function(event){
	//////////////console.log("clicked on a list element");
	//////////////console.log($(this).parent());
	if($(this).parent().hasClass('autocomplete-content')){
		//////////////console.log("closing the dropdown");
		$(".autocomplete").autocomplete("close");
	}
});

/***
var update_last_successfull_query = function(query,result_text){
	if(!((_.isUndefined(query)) || (_.isNull(query)))){
		var successfull_query = "";
		//////////////console.log("query is:" + query);
		//////////////console.log("Result text:" + result_text);
		_.each(query.split(" "),function(word){
			var regex = new RegExp(word + "\\b");
			//////////////console.log("Regex is:" + regex);
			if(regex.test(result_text) === true){
				//////////////console.log("matches.");
				successfull_query += word + " ";
			}
		});
		//////////////console.log("successfull_query is:" + successfull_query);
		if(!(_.isEmpty(successfull_query))){
			$("#last_successfull_query").attr("data-query",successfull_query);
		}
	}
}

var search = function(input){

	//////////////console.log("--------- called search with input:" + input);

	var contexts_with_length = prepare_contexts(input);

	
	//////////////console.log("contexts with length are:");
	//////////////console.log(contexts_with_length);

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
	    	//////////////console.log(search_result);
	    	search_result = update_bar_lengths(search_result);
	    	search_result = add_time_to_setup(search_result);
	    	search_result = add_impact_and_trade_action_to_setup(search_result);
	    	search_result = add_tooltips_to_setup(search_result);
	    	search_result = strip_period_details_from_setup(search_result);
	    	search_result = update_falls_or_rises_text(search_result);
	    	search_result = set_stop_losses(search_result);
	    	////////////console.log(search_result);
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
/***
		_.each(search_result.impacts[0].statistics,function(statistic){
			var sum = statistic.total_up + statistic.total_down;
			var percent = statistic.total_up/sum;

			if(statistic.time_frame_name == "1 week"){

				if(percent >= 0.55){
					gold.push(_.range(Math.floor(multiple)));
				}
			}
			else if(statistic.time_frame_name == "1 month"){
				if(percent >= 0.61){
					gold.push(_.range(Math.floor(multiple)));
				}
			}
			else{
				if(percent >= 0.66){
					gold.push(_.range(Math.floor(multiple)));
				}
			}
			
		});
		**/
// so this sup business does not work.
// let me improve the search.
var update_coin_counts = function(search_result){
	var max_units = 9;
	if(!_.isEmpty(search_result.impacts[0].statistics)){
		//var multiple = max_units/(_.size(search_result.impacts[0].statistics));
		var multiple = 9;
		//////////////console.log("multiple is:" + multiple);
		//////////////console.log("size of the statistics of the first impact is:");
		//////////////console.log(_.size(search_result.impacts[0].statistics));
		
		var gold = [];
		var total_time_units = [];
		_.each(search_result.impacts[0].statistics,function(statistic,key,list){
			if(key == 0){
				if(statistic.total_up >= statistic.total_down){
					gold.push(_.range(Math.floor(multiple)));
				}
			}
		});
		gold = _.flatten(gold);
		search_result.impacts[0].statistics[0]["gold_coins"] = gold;
		//////////////console.log("the gold coins become:");
		//////////////console.log(gold);
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
			statistic["up_down_text"] = "<i class='material-icons' data-icon='call_made'></i>Rises " + statistic.total_up + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "green";
			search_result.bias = 1
		}
		else{
			statistic["up_down_text"] = "<i class='material-icons' data-icon='call_received'></i>Falls " + statistic.total_down + "/" + (total_times) + " times";
			statistic["up_down_text_color"] = "red";	
			search_result.bias = -1
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

// all this has to be ported to result
// for proper display otherwise it will get fucked
// can we get them by date.
var convert_n_day_change_to_superscript = function(search_result){
	var pattern = /(\d+)\sday\schange/
	var match = pattern.exec(search_result.setup);
	search_result.setup = search_result.setup.replace(pattern,'');
	if(!_.isNull(match)){
		search_result.setup = search_result.setup + "<sup>" + match[1] + "</sup>";
	}
	return search_result;
}

// so first we start porting this, then we sort out the individual pages.

var strip_period = function(search_result){
	//////////console.log(search_result.setup);
	var pattern = /(_period_start_\d+(_\d+)?_period_end)/g
	
	var match = pattern.exec(search_result.setup);
	if(!_.isNull(match)){
		
		search_result.setup = search_result.setup.replace(pattern,'');

	}
	return search_result;
}

var strip_period_details_from_setup = function(search_result){
	////////////console.log("came to split period details");
	var pattern = /(<.+?>[^<>]*?)(_period_start_\d+(_\d+)?_period_end)([^<>]*?<.+?>)/g
	
	var match = pattern.exec(search_result.setup);
	if(!_.isNull(match)){
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

// im gonna finish these functions and test it first
// then next step is 

var replace_percentage_and_literal_numbers = function(search_result){
	_.each(_.keys(numeric_literals),function(literal){
		k = new RegExp("\\b" + literal,"gm");
		search_result.setup = search_result.setup.replace(k,numeric_literals[literal]);
	});
	return search_result;
}

var replacer = function(match,ud,offset,string){
	if(ud == "up"){
		return "<i class='material-icons' data-icon='arrow_upward'></i>";
	}
	else{
		return "<i class='material-icons' data-icon='arrow_downward'></i>";
	}
}

// so it already has the html tags.
// next step is further normalization of the UI.

var replace_pattern_with_icons = function(setup){
	
	// do we have something like 
	var end_pattern = new RegExp(/(up|down)(_)(up|down)$/g);
	// if this pattern matches, then knock of the last up/down, with the replacer.
	var pattern = new RegExp(/(up|down)(?=_(down|up))/g);
	var newText = setup.replace(pattern,replacer);
	if(!_.isNull(end_pattern.exec(setup))){
		// we have to repalce that.
		newText = newText.replace(/_(up|down)$/g,replacer);
		newText = newText.replace(/>(_)</g,function(match,ud,offset,string){return '';});
	}


	return newText;
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
	
// @return[Object] [key] : abbreviated indicator name [value] : full name with underscores, can be used for information query. 
// used to populate the what is questions.
// and the time indicator results.
// what happens to dow jones in september?
// historically dow jones tends to rise in september, by an average of
// x/y/z

var indicator_abbreviations_to_names =  function(){
	return {
		"SOK Indicator" : "stochastic_oscillator_k_indicator",
		"SOD Indicator" : "stochastic_oscillator_d_indicator",
		"ADM Indicator" : "average_directional_movement_indicator",
		"DEMA Indicator" : "double_ema_indicator",
		"AO Indicator" : "awesome_oscillator_indicator",
		"TEMA Indicator" : "triple_ema_indicator",
		"SEMA Indicator" : "single_ema_indicator",
		"MACD Indicator" : "moving_average_convergence_divergence",
		"AD Indicator" : "acceleration_deceleration_indicator",
		"RSI Indicator" : "relative_strength_indicator",
		"WR Indicator" : "williams_r_indicator",
		"Aroon Up Indicator" : "aroon_up",
		"Aroon Down Indicator" : "aroon_down",
		"CCI Indicator" : "cci_indicator"
	}
}

var shrink_indicators = function(setup){
	setup = setup.replace("stochastic_oscillator_k_indicator","SOK Indicator");
	setup = setup.replace("stochastic_oscillator_d_indicator","SOD Indicator");
	setup = setup.replace("average_directional_movement_indicator","ADM Indicator");
	setup = setup.replace("double_ema_indicator","DEMA Indicator");
	setup = setup.replace("awesome_oscillator_indicator","AO Indicator");
	setup = setup.replace("triple_ema_indicator","TEMA Indicator");
	setup = setup.replace("single_ema_indicator","SEMA Indicator");
	setup = setup.replace("moving_average_convergence_divergence","MACD Indicator");
	setup = setup.replace("acceleration_deceleration_indicator","AD Indicator");
	setup = setup.replace("relative_strength_indicator","RSI Indicator");
	setup = setup.replace("williams_r_indicator","WR Indicator");
	setup = setup.replace("aroon_up","Aroon Up Indicator");
	setup = setup.replace("aroon_down","Aroon Down Indicator");
	setup = setup.replace("cci_indicator","CCI Indicator");
	return setup;
}

/**
var add_indicator_question = function(search_result){
	_.each(indicator_names(),function(name){
		if(_.contains(search_result.setup,name){
			search_result.question = "What is the" + name + " ?";
		}	
	});
}
**/

// add what is
// solve arron_


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
	//////////////console.log("came to trim with entity name:" + entity_name);
	if(entity_name.indexOf("_") != -1){

		var idx = entity_name.indexOf("_");
		var part_after_underscore = entity_name.slice(idx,entity_name.length);
		var part_before_underscore = entity_name.slice(0,idx);
		search_result.setup = search_result.setup.replace(part_after_underscore,'');
		//////////////console.log("part before underscore:");

		search_result = process_setup_component(part_before_underscore,search_result,entity_name);
	}
	return search_result;
}



// for eg
// is it either true/false for the indicator/subindicator.
var is_binary = function(year_wise_data){
	//////////console.log("checking binary with year wise data");
	//////////console.log(year_wise_data);
	var result = true;
	for(year in year_wise_data){
		//////////console.log("sum-===--==============>");
		//////////console.log(Number(year_wise_data[year][0]) + Number(year_wise_data[year][1]));
		//////////console.log("sum-===--==============>");
		if((Number(year_wise_data[year][0]) + Number(year_wise_data[year][1])) > 2){
			result = false
		}	
	}
	return result;
}

var is_time_based_subindicator = function(search_result){
	//////////console.log("************************");
	//////////console.log("came to check time based subindicator with setup:" + search_result.setup);
	
	var time_based_pattern = new RegExp(/first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/g);
	
	var a = _.isNull(time_based_pattern.exec(search_result.tags));
	
	var b = _.isNull(time_based_pattern.exec(search_result.information[0]));
	
	if((a == true) && (b == true)){
		//////////console.log("returning false");
		return false;
	}
	else{
		//////////console.log("a is: " + a);
		//////////console.log("b is:" + b);
		//////////console.log("informatino:");
		//////////console.log(search_result.information);
		//////////console.log("returning true");
		return true;
	}
}

var get_predicate = function(search_result){
	//////console.log("setup is:" + search_result.setup);
	var pattern = new RegExp(/\s(in|on)\s(.*)$/);
	var result = pattern.exec(search_result.setup);
	//////console.log("result is:" + result);
	var predicate = null;
	if(!_.isNull(result)){
		predicate = result[2].replace(/(\(.*\))/,'');
	}
	//////console.log("####################################");

	return predicate;
}

var get_preposition = function(search_result){
	var pattern = new RegExp(/\s(in|on)\s/);
	var result = pattern.exec(search_result.setup);
	var predicate = null;
	if(!_.isUndefined(result[1])){
		predicate = result[1];
	}
	return predicate;
}

/***
Should return
rose_or_fell : "rose" || "fell",
rose_or_fell_times : integer,
strongly_positive_years : [],
strongly_negative_years : [],
last_couple_of_years : "positive/negative/mixed";
best_year : 
worst_year : 

***/	
var get_trend = function(year_wise_data){
	var summary = "";
	var current_year = (new Date()).getFullYear();
	var _sorted = {}
	var strong_threshold = 60;
	// starts from penultimate year.
	var total_years_to_consider_as_last_couple = 3;
	var rose_times = 0;
	var fell_times = 0;
	var strongly_positive_years = [];
	var strongly_negative_years = [];

	for(year in year_wise_data){
		
		var k = year_wise_data[year];

		if((k[0] + k[1]) == 0){
			//////console.log("year:" + year + " has no rise or fall data");
		}
		else
		{
			var percentage_rise = (Number(k[0])/(Number(k[0]) + Number(k[1])))*100;
			var percentage_fall = (Number(k[1])/(Number(k[0]) + Number(k[1])))*100;
			//////////console.log("year" + year + " fall :" + percentage_fall + " rise :" + percentage_rise);
			//////////console.log("percentage rise is:" + percentage_rise);
			//////////console.log("percentage fall is:" + percentage_fall);
			if(percentage_rise >= strong_threshold){
				strongly_positive_years.push(year);
			}
			
			if(percentage_fall >= strong_threshold){
				strongly_negative_years.push(year);
			}

			_sorted[year] = [percentage_rise,percentage_fall];
			if(k[0] > k[1]){
				rose_times += 1;
			}
			else if(k[0] < k[1]){
				fell_times += 1;
			}
		}
	}

	year_wise_data = _.sortKeysBy(year_wise_data,function(value,key){
		return Number(key);
	});


	var keys = _.sortBy(Object.keys(_sorted),function(k){return _sorted[k][0]});

	_sorted = _.sortKeysBy(_sorted, function (value, key) {
	    ////////console.log("value 0 is:" + value[0]);
	    return Number(value[0]);
	});

	// penultimate three.
	////////console.log("keys is:");
	////////console.log(keys);

	var best_year = _.last(keys);
	
	var worst_year = _.first(keys);

	var last_couple_positive = 0;
	var last_couple_negative = 0;
	var last_couple_total = 0;
	
	//////console.log("sorted data is:");
	//////console.log(_sorted);

	_.map((Object.keys(year_wise_data).reverse()),function(val,key){
		if(key > 0 && key < total_years_to_consider_as_last_couple){
			last_couple_total++;
			//////console.log("year is:" + val + " data is:" + _sorted[val]);
			if(!_.isUndefined(_sorted[val])){
				if(_sorted[val][0] > _sorted[val][1]){
					////////console.log("took as positive");
					last_couple_positive+=1;
				}
				else if(_sorted[val][1] > _sorted[val][0]){
					////////console.log("took as negative");
					last_couple_negative+=1;
				}
				else{

				}
			}
		}
	});

	var last_couple_of_years_trend = null;
	var last_couple_of_years_color = "grey-text text-darken-2";

	//////////console.log("last couple positive:" + last_couple_positive);
	//////////console.log("last couple negative:" + last_couple_negative);
	if(last_couple_positive >= 2){
		last_couple_of_years_color = "green-text";
		last_couple_of_years_trend = "mostly positive";
	}
	else if(last_couple_negative >= 2){
		last_couple_of_years_color = "red-text";
		last_couple_of_years_trend = "mostly negative";
	}
	else{
		//if(last_couple_total >= 3){
		last_couple_of_years_trend = "mixed";
		//}
	}

	var rose_or_fell = null;
	
	var rose_or_fell_times = null;
	
	if(rose_times >= fell_times){
		rose_or_fell = "rose";
		rose_or_fell_times = rose_times;
	}
	else{
		rose_or_fell = "fell";
		rose_or_fell_times = fell_times;
	}


	return {
		rose_times: rose_times,
		fell_times: fell_times,
		rose_or_fell_times: rose_or_fell_times,
		rose_or_fell: rose_or_fell,
		strongly_positive_years: strongly_positive_years,
		strongly_negative_years: strongly_negative_years,
		best_year: best_year,
		worst_year: worst_year,
		last_couple_of_years_trend: last_couple_of_years_trend,
		last_couple_of_years_color: last_couple_of_years_color
	}
}

var add_comma_seperated_list = function(list,text,trend_object,positive_or_negative){

	_.map(list,function(year,key){
		text +=  year;
		if(_.size(list) == 1){
			text += ".";
		}
		else{
			if(key == (_.size(list)) - 2){
				text += " and ";
			}
			else if(key == (_.size(list)) - 1){
				text += ".";
			}
			else{
				text += ",";
			}
		}
	});

	if(positive_or_negative == "positive"){
		summary += (" The most positive year was: " + trend_object["best_year"]);
	}
	else if(positive_or_negative == "negative"){
		summary += (" The most negative year was: " + trend_object["worst_year"]);
	}

	return text;
}

var add_best_worst_year = function(summary,trend_obj){
	summary += (" The most positive year was: " + trend_obj["best_year"]);
	summary += (" The most negative year was: " + trend_obj["worst_year"]);
	return summary;
}

var build_time_based_indicator_summary = function(search_result){
	var summary = "";
	////////console.log("------------------------------>");
	////////console.log(search_result.setup);
	var trend = get_trend(search_result.year_wise_data);
	
	//////console.log(trend);
	//////console.log("------------------------------>");
	
	// i think this is being interpreted as time based.
	if(is_time_based_subindicator(search_result) == true){
		//////////console.log("is time based" + search_result.setup);
		if(is_binary(search_result.year_wise_data)){
			//////////console.log("is binary");
			if(!_.isNull(get_predicate(search_result))){
				//////////console.log("predicate is not null");
				// Nifty 
				// first fix the trend.
				summary = "";
				if(trend["rose_or_fell"] == "fell"){
					summary += '<span class="red-text"><i class="material-icons" data-icon="trending_down"></i>';
				}
				else if(trend["rose_or_fell"] == "rose"){
					summary += '<span class="green-text"><i class="material-icons" data-icon="trending_up"></i>';
				}

				summary += "In the last " + _.size(Object.keys(search_result.year_wise_data)) + " years, " + search_result.target + " " + trend["rose_or_fell"] + " " + get_preposition(search_result) + " " + get_predicate(search_result) + " " + trend["rose_or_fell_times"] + " times.</span>";
				// in the last couple of years, the trend has been positive.
			}
		}
		else{
			//////console.log("predicate is:" + get_predicate(search_result));
			if(_.size(trend["strongly_positive_years"]) > 0){

				summary = get_predicate(search_result) + " was ";
				summary += "strongly positive for " + search_result.target +  " in ";
				summary = add_comma_seperated_list(trend["strongly_positive_years"],summary,trend);
				
			}
			if(_.size(trend["strongly_negative_years"]) > 0){
				summary += get_predicate(search_result) + " was ";
				summary += "strongly negative for " + search_result.target +  " in ";
				summary = add_comma_seperated_list(trend["strongly_negative_years"],summary,trend);
			}
			//summary = add_best_worst_year(summary,trend);
		}

	}
	else{
		if(_.size(trend["strongly_negative_years"]) > 0){
			summary = search_result.target + " reacted ";
			summary += "negatively to this indicator in ";
			summary = add_comma_seperated_list(trend["strongly_negative_years"],summary);
			summary += ". It reacted positively to this indicator in ";
			summary = add_comma_seperated_list(trend["strongly_positive_years"],summary);
		}
		else if(_.size(trend["strongly_positive_years"]) > 0){
			summary = search_result.target + " reacted ";
			summary += "positively to this indicator in ";
			summary = add_comma_seperated_list(trend["strongly_positive_years"],summary);
		}
		//summary = add_best_worst_year(summary,trend);
	}

	search_result.summary = summary;

	if(!_.isNull(trend["last_couple_of_years_trend"])){

		search_result.last_couple_of_years =  "<span class='" + trend["last_couple_of_years_color"] + "'>" + "In the last couple of years, the trend has been " + trend["last_couple_of_years_trend"] + "</span>"; 
	}	
	
}

var MONTHS = {

	"1" : "January",
	"2" : "February",
	"3" : "March",
	"4" : "April",
	"5" : "May",
	"6" : "June",
	"7" : "July",
	"8" : "August",
	"9" : "September",
	"10" : "October",
	"11" : "November",
	"12" : "December"

}
var get_month = function(int){
	return MONTHS[int.toString()];
}	

/***

Will generate something like this:
This indicator performed best in the year 2014, with Nifty 50 rising 68% of the times.
The indicator performed worst in the year 2011, with Nifty 50 rising 50% of the times.
The current year has seen Nifty-50 rise 68% of the times whenever this indicator is triggered.

-- okay so after this is what exactly ?
-- summaries -> finish today, with the new templates
-- chart also today
-- running from 8 - 9.30 : then 1 hour prograaming.
-- so i have 4 hours till then,
-- maybe minor highlighting
-- but that's about it.
-- and then checking the calculation accuracy
-- minimum one week more is necessary.

****/
var get_statistical_summary = function(search_result){
	var summary = "";
	var current_year = (new Date()).getFullYear();
	var _sorted = {}

	for(year in search_result.year_wise_data){
		var k = search_result.year_wise_data[year];
		var percentage_rise = (k[0]/(k[0] + k[1]))*100.0;
		var percentage_fall = (k[1]/(k[0] + k[1]))*100.0;
		_sorted[year] = [percentage_rise,percentage_fall];
	}	
	if(search_result.bias == 1){
		_.sortKeysBy(_sorted, function (value, key) {
		    return value[0];
		});
	}
	else{
		_.sortKeysBy(_sorted, function (value, key) {
		    return value[1];
		});	
	}

	//////////console.log("sorted is:");
	//////////console.log(_sorted);


	var current_year_data = {current_year: _sorted[current_year]};

	delete _sorted[current_year];

	var rising_or_falling = (search_result.bias == 1) ? "rising" : "falling";

	var percentage_index = (search_result.bias == 1) ? 0 : 1

	summary += "This indicator performed the best in the year " + _.last(Object.keys(_sorted)) + " with " + search_result.target + " " + rising_or_falling + " " +  _.last(Object.values(_sorted)[percentage_index]) + "% of the times.";

	// now how to display this ?
	summary += "This indicator performed worst in the year " + _.first(Object.keys(_sorted)) + " with " + search_result.target + " " +rising_or_falling + " " +  _.first(Object.values(_sorted)[percentage_index]) + "% of the times.";

	if(!_.isUndefined(current_year_data[percentage_index])){
		summary += "The current year has seen " + search_result.target + rising_or_falling + current_year_data[percentage_index] + "% of the times when this indicator is triggered.";
	}

	search_result.summary = summary;
	//////////console.log("summary is:");
	//////////console.log(summary);
	return search_result ;

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

var remove_close = function(search_result){
	search_result.setup.replace(/\'s close/,'');
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
	$("#search").val($(this).attr("data-related-query"));
	search_new($(this).attr("data-related-query"));
});

var toggle_search_field_label = function(add_or_remove){
	$("label[for='autocomplete-input']").toggleClass("active");
}

$(document).on("click",'.index_chip',function(event){

	$("#logo,#exchanges").slideUp('fast',function(){
				
	});
	$(".default_sectors").first().hide();
	
	/**
	this is used in the search complete callback to show the first search result.
	EARLIER CODE TO SHOW A SEARCH RESULT FOR THIS INDEX.
	$(this).data("clicked","yes");
	$("#autocomplete-input").val($(this).attr("data-related-query"));
	search_new($(this).attr("data-related-query"));
	$("label[for='autocomplete-input']").addClass("active");
	***/
	
});



$(document).on('click','.chip',function(event){
	console.log("clicked chip with category:" + $(this).attr("data-category"));
	// if its parent is the row chip.
	if($(this).hasClass("show_more_chips")){
		// so its show more.
		console.log("it is show more chips");
		$(".additional_chips").show();
	}
	else if($(this).hasClass("show_less_chips")){
		console.log("it is show less chips");
		$(".additional_chips").hide();
	}
	else if($(this).hasClass("show_more_query_chips")){
		console.log("it is show more query chips");
		$(".query_chips").slideToggle();
	}	
	else{
		if($(this).hasClass("default_sector")){
			console.log("it is default sector");
			$("#logo").slideUp('fast',function(){
				
			});
			$(".default_sectors").first().hide();
		}
		else{

		}

		//console.log("doing search new, data category is ------------>");
		//console.log($(this).attr("data-category"));
		//
		//search_new($(this).attr("data-category"));
		
		//$("#autocomplete-input").val($(this).attr("data-category"));

		//$("#autocomplete-input").trigger("click");
		// if it is ready then show it.
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
	"A new idea is delicate. It can be killed by a sneer or a yawn; it can be stabbed to death by a quip and worried to death by a frown on the right man's brow." : "Ovid",
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
	"There's only one boss, the customer. He can fire everyone from the Chairman down, simply by spending his money somewhere else." : "Sam Walton",
	"I am become death, the destroyer of worlds" : "Oppenheimer after the first nuclear test, quoting the Bhagavad Gita.",
	"The way to become rich is to put all your eggs in one basket and then watch that basket" : "Andrew Carnegie"
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


function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}


var update_information_cards_new = function(text,div_id,type){
	//console.log("came to update information cards new");
	// it should display the cards in the right place by a js erb.
	if(type == "primary_entity"){
		$.get('/stocks/' + expand_indicators_for_information_query(text).trim() + ".js",{entity : {div_id : div_id}});
	}
	else if(type == "impacted_entity"){
		$.get('/stocks/' + expand_indicators_for_information_query(text).trim() + ".js",{entity : {div_id : div_id}});	
	}
	else if(type == "indicator"){
		$.get('/indicators/' + expand_indicators_for_information_query(text).trim() + ".js",{entity : {div_id : div_id}});
	}
}

$(document).on('click','.tab',function(event){
	$(this).parent().parent().next().show();
})


/***
text -> whatever
div_id -> the div_id of the main card
type -> indicator/primary_entity/impacted_entity
***/
var update_information_cards = function(text,div_id,type){
	update_information_cards_new(text,div_id,type);
	/****
	$.get(
		'/search',
		{information: expand_indicators_for_information_query(text)}).done(function(data) {
		
		 	if(!_.isEmpty(data["results"])){

        		result = data["results"][0]["_source"];

            	title = capitalizeFirstLetter(result["information_name"]).replace(/_/g," ");

            	content = capitalizeFirstLetter(result["information_description"]).replace(/\[\d+\]/,'').substring(0,150) + "...";

            	link = result["information_link"];

            	var icon = null;

            	var obj = {title: title, content: content, link: link};

            	if(type == "primary_entity"){
            		obj.entity = 1
            		obj.icon = "dns";
            		obj.stock_quote_link = obj.title.replace(/\s/,'+');
            		obj.entity_link = "/stocks/" + obj.title;
            	}
            	else if(type == "impacted_entity"){
            		obj.entity = 1
            		obj.icon = "dns";
            		obj.stock_quote_link = obj.title.replace(/\s/,'+');
            		obj.entity_link = "/stocks/" + obj.title;
            	}

            	else if(type == "indicator"){
            		obj.indicator = 1;
            		obj.icon = "timeline";
            		obj.entity_link = "/indicators/" + obj.title;
            	}



            	if(_.isUndefined(template)){
					var template = _.template($('#information_card_template').html());
					$('#' + div_id).find(".information").first().append(template(obj));
				}

        	}

	});

	****/
}

_.mixin({
    isBlank: function(string) {
      return (_.isUndefined(string) || _.isNull(string) || string.trim().length === 0)
    }
});

_.mixin({
    sortKeysBy: function (obj, comparator) {
        var keys = _.sortBy(_.keys(obj), function (key) {
            return comparator ? comparator(obj[key], key) : key;
        });
    
        return _.object(keys, _.map(keys, function (key) {
            return obj[key];
        }));
    }
});


// so suppose i want an indicators index page
// i want an entities page
// we can just have cards, one after the other.
// showing the relevant information.
// under the exchanges
// how to show related queries
// give me a place to go positive and negative indicators.
// so some queries per exchange 
// we can have.to give people the hang of it.
// nice big heading.
// with some cards side by side
// what happens to nasdaq when nifty falls.
// can we have some top ones for reliance ?
// out of the latest 
// we are already calculating latest trends
// can we curate entity specific hash.
// should be simple enough.
// to generate positive and negative top trending result ids.
// so we have an exchanges endpoint.
// we will just query by index type.

$(document).on('click','.facebook_share',function(event){
	
	event.preventDefault();
	
	var url = $(this).attr("href");
	
	FB.ui({
	  method: 'share',
	  link: url,
	}, function(response){
		alert("Facebook Share Error");
	});

});

// the search result div.
var load_entity_information = function(args){
	var the_div = args["search_result_card"];
	var primary_entity = the_div.attr("data-primary-entity");
	var impacted_entity = the_div.attr("data-impacted-entity");
	var indicator = the_div.attr("data-indicator");
	var div_id = the_div.attr("id");

	if(!_.isBlank(primary_entity)){
		//////////console.log("primary entity not undefined and is:" + primary_entity);
		update_information_cards(primary_entity,div_id,"primary_entity");
	}
	
	if(!_.isBlank(impacted_entity)){
		//////////console.log("impacted entity not undefined and is:" + impacted_entity);
		update_information_cards(impacted_entity,div_id,"impacted_entity");
	}
	
	if(!_.isBlank(indicator)){
		//////////console.log("indicator not undefined and is:" + indicator);
		update_information_cards(indicator,div_id,"indicator");
	}
}


$(document).ready(function(){

	$.ajaxSetup({ cache: true });
	  $.getScript('https://connect.facebook.net/en_US/sdk.js', function(){
	    FB.init({
	      appId: '584959032110656',
	      version: 'v2.7'
	    });     
	    $('#loginbutton,#feedbutton').removeAttr('disabled');
	    FB.getLoginStatus(updateStatusCallback);
	});

	// now lets see if this works.


	var quote = _.sample(Object.keys(quotes), 1);
	var quote_author = quotes[quote];
	$("#quote").text(quote);
	$("#quote_author").text(quote_author); 
    //
    $('.tooltip').tooltipster();
    $('input.autocomplete').autocomplete({
      data: {
        
      },
      onAutocomplete: function(text,payload) {
      	// now check if it has the div_id.
      	// and so on and so forth.
      	// val
      	// div_id
      	console.log("triggered on autocomplete");
      	console.log("directly calling payload lin");
      	console.log(payload["lin"]);
      	console.log(payload);
      	
      	if(payload["div_id"]){
      		$(".search_result_card").hide();
      		var the_div = $("#" + payload["div_id"]);
      		$(the_div).show();
      		// we want to also show these cards.
      		load_entity_information({search_result_card : the_div})

      	}
      	else if(payload["lin"]){
      		console.log("got payload link");
      		console.log(payload["lin"]);
      		window.location.replace(payload["lin"]);
      	}
      }
    });
    init_js_plugins();
});

var init_js_plugins = function(){
	$('.datepicker').datepicker();
}

$( document ).ajaxSend(function() {
  console.log("sending ajax request");
  //$("#progress").css("visibility","visible");
});

$( document ).ajaxComplete(function() {
  //$("#progress").css("visibility","hidden");
  console.log("ajax complete");
  init_js_plugins();
});

$( document ).ajaxError(function() {
  //$("#progress").css("visibility","hidden");
  console.log("ajax error");
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