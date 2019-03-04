/***
returns true if the text sent in from the search box
(as is) has found a match.
***/
var direct_query_has_results = function(search_results){
	return _.length(search_results) > 0;
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

// we take the last space delimited word.
// check if we have an entity(and it is in the query string) otherwise break and query for that
// and proceed.


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
***/
var expand_query = function(query){
	// so on keypress, it will check if the query still has whatever 
	// is there in each of the info div's above, otherwise will remove them
	// then when the time comes to expand.
	// we first get state.
	// i.e check each one after the other, and query 
	// for whichever one is not there.
	// on returning the query -> if the user pressed tab, 
	// then it adds that to the correct context.
}

