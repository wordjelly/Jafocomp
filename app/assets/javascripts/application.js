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

$(document).on('keyup','#search',function(event){
	// if the event is space.
	// don't do anything.
	// console.log(event.originalEvent.keyCode);
	// console.log(event.keyCode);
	if(event.keyCode == 32){
		console.log("got space, doing nothing.");
	}
	else{
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
	}
});

/***
so how would this work exactly 
suppose i say 
buy gold when 
***/

var render_search_result = function(search_result){	
	if(_.isUndefined(template)){
		var template = _.template($('#search_result_template').html());
	}
	$('#search_results').append(template(search_result));
	$("time.timeago").timeago();
}

var prepare_contexts = function(input){
	
	var existing_contexts = JSON.parse($("#top_result_contexts").attr("data-context"));
	
	
	var existing_contexts_object = null;
	
	
	var existing_contexts_object_values = _.map(existing_contexts,function(e){
		return {
			"words" : e.split(/\:/),
			"length" : e.length,
			"score" : 0,
			"word_mapping" : {},
			"original_key" : e
		}
	});

	existing_contexts_object = _.object(existing_contexts,existing_contexts_object_values);
	

	// remove multiple spaces
	var context = input.replace(/\s{2}/g,'');
	
	// split on space.
	context = context.split(/\s/);
	
	// take everything before the space
	context = context.slice(0,-1);
	
	// get rid of the stopwords
	context = _.reject(context, function(element){
		_.has(stopwords,element);
	});
	
	// sort alphabetically
	//context.sort();
	

	//console.log("sorted context:");
	//console.log(context);
	
	console.log("context is:" + context);
	console.log("existing contexts object:");
	console.log(existing_contexts_object);


	// basically we are scoring the existing contexts for congruence with all the words before the last word in the currently typed search string
	// we take each word(Except) the penultimate in the currently typed search string, and check it for being a part of an existing context.
	// if it is found in an existing context, we increment hte score of that context in the contexts_object, and add the current word as a mapping
	_.each(context,function(word){
		for(key in existing_contexts_object){
			_.each(existing_contexts_object[key]["words"],function(eword){
				if(eword.toLowerCase().indexOf(word.toLowerCase()) != -1){
					existing_contexts_object[key]["score"] += 1
					if(!_.has(existing_contexts_object[key]["word_mapping"],word)){
						existing_contexts_object[key]["word_mapping"][word] = eword;
					}
				}
			});
		}
	});
	// the score may be same, we use the length as a decimal.
	for(key in existing_contexts_object){
		existing_contexts_object[key]["score"] = existing_contexts_object[key]["score"] + (1/existing_contexts_object[key]["length"]);
	}

	// now sort by the best one.
	// and what do you want of them.
	var sorted_values = _.sortBy(_.values(existing_contexts_object), function(o) { return -o["score"]; });

	console.log("sorted values are:");
	console.log(sorted_values);

	var original_word_wordgrams = [];
	// go over the context words now, 
	// and get their mapped values from the first one of the sorted vlaues
	// that is one context
	// the other context is the first sorted value "original key"
	// and those are the two contexts for the query.
	// basically the scoring went wrong here.
	if(!_.isEmpty(sorted_values)){
		var first_sorted_value = _.first(sorted_values);

		context = _.map(context,function(word){
			console.log("mapping context word:" + word);
			var first_matching_word =  _.first(_.filter(first_sorted_value["words"],function(ww){
				console.log("ww is:" + ww);

				return (ww.toLowerCase().indexOf(word.toLowerCase()) != -1);
			}));
			console.log("first matching word:" + first_matching_word);
			if (_.isNull(first_matching_word)){
				console.log("returning null");
				return null;
			}
			else{
				console.log("returning first matching word:" + first_matching_word);
				return first_matching_word;
			}
		});

		context = _.reject(context,function(w){
			return _.isNull(w);
		});

		original_word_wordgrams = prepare_wordgrams(first_sorted_value["words"]);

	}
	context.sort();
	
	//console.log("context finally becomes:");
	//console.log(context);

	/***
	make wordgrams from the assembled context
	***/
	wordgrams = prepare_wordgrams(context);

	// use the original words and prepare another wordgram ?
	// 
	

	//var wordgrams_united = _.union(wordgrams,original_word_wordgrams);

	//return _.object(wordgrams_united,_.map(wordgrams_united,function(k){
	//	return k.length;
	//}));	
	return _.uniq(original_word_wordgrams);
}

/***
returns the stop loss, with the least amount of loss.
***/
var get_most_economic_stop_loss = function(statistic){
	return _.sortBy(statistic.stop_losses,function(sl){
		return sl.maximum_loss;
	})[0];
}

/****
@param[Array] context : array of contexts(individual words)
@return[Array] wordgrams : array of wordgrams.
@eg: given context as ["happy","new","year"], will generate
["happy","happy:new","happy:new:year","new","new:year"]
****/
var prepare_wordgrams = function(context){
	var wordgrams = [];
	console.log("contexts coming into prepare wordgrams");
	console.log(context);
	_.each(context,function(word,key,context){
		var chain = word;
		wordgrams.push(chain);
		console.log("chain is: " + chain);
		_.each(context,function(w,k,c){
			if(k > key){
				chain = chain + ":" + w;
				console.log("chain becomes:" + chain);
				wordgrams.push(chain);
			}
		});
	});
	return wordgrams;
}

var prepare_query = function(input){
	// the last word after the space becomes the prefix input.

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


var set_stop_losses = function(search_result){
	_.map(search_result.impacts[0].statistics,function(statistic){
		statistic.most_economic_stop_loss = get_most_economic_stop_loss(statistic);
	});
	return search_result;
}

// now add the impacts and from tomorrow start developing the springapp for a live online version

var search = function(input){

	console.log("--------- called search with input:" + input);

	var contexts_with_length = prepare_contexts(input);

	
	console.log("contexts with length are:");
	console.log(contexts_with_length);

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

	    $('.tooltip').tooltipster({
		    content: 'Loading...',
		    contentAsHTML: true,
    		interactive: true,
		    // 'instance' is basically the tooltip. More details in the "Object-oriented Tooltipster" section.
		    functionBefore: function(instance, helper) {
		        
		        var $origin = $(helper.origin);

		        // we set a variable so the data is only loaded once via Ajax, not every time the tooltip opens
		        if ($origin.data('loaded') !== true) {

		        	//console.log(instance);

		            $.get('/search',{information: $origin.attr("data-name")}).done(function(data) {

		            	result = data["results"];

		            	title_string = "<h5 class='white-text'>"+ prepare_information_title(result["information_name"]) +"</h5><br>";

		            	content_string = result["information_description"] + "<br>";

		            	link_string = '';

		            	if(!_.isEmpty(result["information_link"])){
		            		console.log("there is an information link");
		            		link_string = "<a href=\"" + result["information_link"] + "\">Read More</a>";
		            		console.log("link string becomes:");
		            		console.log(link_string);
		            	}
		            	
		            	var content = title_string + content_string + link_string

		            	console.log("content" + content);

		                instance.content(content);
		               
		                $origin.data('loaded', true);
		            });
		        }
		    }
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
// let's do this based on how many are positive and how many are negative.
var update_bar_lengths = function(search_result){
	
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
	search_result.setup = search_result.setup  + " (" + strftime('%-d %b %Y', d) +  ")";
	return search_result;
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

var strip_period_details_from_setup = function(search_result){
	var pattern = /(<.+?>[^<>]*?)(_period_start_\d+_period_end)([^<>]*?<.+?>)/g
	search_result.setup = search_result.setup.replace(pattern,'$1 $3');
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


// I want a side by side comparison, in one tab only.
// with a switch to show what exactly is happening.

/****
tooltipster ajax.
****/


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
	"A man's worth is no greater than his ambitions." : "~ Marcus Aurelius, Emperor of Rome",
	"We really can't forecast all that well, and yet we pretend that we can, but we really can't." : "Alan Greenspan",
	"People who advocate simplicity have money in the bank; the money came first, not the simplicity." : "Douglas Coupland, The Gum Thief",
	"There will be a backlash from those who don't benefit from the system" : "Rahul Bajaj, Indian Automobile Billionaire",
	"What do you mean there is no money in the bags?" : "Ocean's Eleven",
	"Misdirection, what the eyes see and the ears hear, the mind believes" : "Gabriel, Swordfish(2001)",
	"Don't *ever* risk your life for an asset. If it comes down to you or them... send flowers." : "Nathan Muir, Spy Game(2001)",
	"Man sacrifices his health in order to make money. Then he sacrifices money to recuperate his health" : "The Dalai Lama",
	"Ah well! You will soon be dead, and then you will own just as much of this earth as will suffice to bury you." : "Hindu yogi, replying to Alexander the Great",
	"The world is in Me. The world cannot contain Me. The universe is in Me. I cannot be confined in the Universe. Greece , Rome and Persia are in Me. The suns and stars rise and set in Me." : "Indian yogi, on being asked by Alexander the Great to accompany him to Athens."
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