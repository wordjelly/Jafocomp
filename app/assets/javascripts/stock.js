$(".result").each(function(index){
	var search_result = $(this).attr("data-result");
	search_result = JSON.parse(search_result);
	console.log(search_result);
	search_result = prepare_search_result(search_result,autocomplete_suggestions_hash,total_positive,total_negative,categories,related_queries);
	draw_chart(("search_result_chart_" + $(this).attr("id")),search_result);
});

// lazy loading.

