$(document).ready(function(){
	console.log("Ready");
	console.log($("#_result"));
	var result = $("#_result");
	console.log(result);
	if(!_.isEmpty(result)){
		var search_result = $("#_result").attr("data-result");
		search_result = JSON.parse(search_result);
		console.log(search_result);
		display_search_results([search_result],"");
		$(".search_result_card").first().show();
	}
	else{
		console.log("no result");
	}
});

var update_title_and_description = function(search_result){
	$("#title").val(search_result.setup);
	$("#meta_description").val(search_result.description);
};

var update_twitter_cards_data = function(search_result){

};
