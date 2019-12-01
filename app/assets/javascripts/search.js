/***
returns true if the text sent in from the search box
(as is) has found a match.
***/
var direct_query_has_results = function(search_results){
	return _.size(search_results) > 0;
}

var get_primary_entity = function(){
	return $("#primary_entity").attr("data-name");
}

var get_secondary_entity = function(){
	return $("#secondary_entity").attr("data-name");
}

var get_subindicator = function(){
	return $("#subindicator").attr("data-name");
}

var get_indicator = function(){
	return $("#indicator").attr("data-name");
}

/***
@param[String] text: the query text
@param[Array] context: the contexts for the query
***/
var get_search_suggestions = function(text,context,last_successfull_query,whole_query){
	$("#query_suggestions").html("");
	var template = _.template($('#suggest_query_template').html());
	$.ajax({
	  	url: "/search",
	  	type: "GET",
	  	dataType: "json",
	  	data:{query: whole_query, suggest_query: text, context: context, last_successfull_query: last_successfull_query}, 
	  	success: function(response){
	  		//console.log(response);

	  		query_suggestion_results = response["results"]["query_suggestion_results"];
	  		search_results = response["results"]["search_results"];
	  		effective_query = response["results"]["effective_query"];
	  		//console.log("response is:");
	  		//console.log(response);
	  		//console.log("effective_query" + effective_query);
	  		// these have to be rendered by another function.
	  		// what do we do in this case.
	  		// buy gold oil
	  		// buy gold when oil
	  		// successfull query in this case is not the input.
	  		// but rather the buy gold when oil's 
	  		// 
	  		display_search_results(search_results,effective_query);
	  		// we need to update the search filed with effective_query
	  		if(!_.isNull(effective_query)){
	  			$("#search").val(effective_query);
	  		}
	  		// the last remaining thing is a match query, that is also executed server side, if the autocomplete doesn't produce anything.
	  		// that is the third fallback.
	  		// i will do that tomorrow, after testing all this.
	  		_.each(query_suggestion_results,function(search_result,index,list){
				search_result = search_result['_source'];
				$('#query_suggestions').append(template(search_result));  			
	  		});
	  	}
	});
}

var do_match_query = function(input){
	$.ajax({
	  	url: "/search",
	  	type: "GET",
	  	dataType: "json",
	  	data:{query: input, basic_query: true}, 
	  	success: function(response){
	  		var search_results = response['results']['search_results'];

	    	display_search_results(search_results,input);
	  	}
	})

}




/***
will try to expand the current query.
will split on whitespace
first checks if a primary entity exists or not.
then checks if a secondary entity exists or not.
then checks if an indicator exists or not.
then checks for subindicators.

eg: buy ap

what happens here.

ap -> query for category "entity", and gets results
becomes buy apple, stores apple-computers in div, with id (primary_entity)
then user types 
buy apple computer re
checks -> get the primary entity (check if exists in query string)
then fires either for subindicator or secondary entity.
shows the two options in dropdown
takes the entity as the primary option, user can either press backspace
and select the secondary option or whatever.
if we have a primary, and a subindicator -> cant do anything
if we have a primary, a secondary, => then proceed for indicator, and subindicator
buy apple computer when reliance

flow is like this -> main query returned nothing -> so we did suggested query -> inside that, it got some results -> so it then merged and reran the main query -> and returned both the suggestions and the results of the main query together.

***/
var expand_query = function(query){
	var last_word = _.last(query.split(" "));

	var last_successfull_query = $("#last_successfull_query").attr("data-query");
	// send the last successfull query only if it is present in the currently sent query, otherwise it is meaningless and should be cleared ideally.
	last_successfull_query = (query.indexOf(last_successfull_query) !== -1) ? last_successfull_query : null;
	if(_.isUndefined(get_primary_entity())){
		get_search_suggestions(last_word,["entity","time_based_subindicator","indicator","subindicator"],last_successfull_query,query);
		//build_search_query(last_word,["entity"]);
		// so the suggestions that come back, will have to be shown
		// in some kind of a suggestion window.
		// we will add a simple collection 
		// so that we don't complicate things.
		// we will use the first suggestion and fire a secondary query.
		// and we will keep the input in the query box the same.
		// we will need another template for that part.
	}
	else
	{
		// context will be "entity","time_based_subindicator"
		// there is a time, when we may have to search for timebased or entity.
		// their contexts can be multiple
	}
}

