$(document).ready(function(event){
	console.log("hit doc ready");
	$(".result").each(function(index){
		console.log("iterating result");
		console.log("iterating");
		var search_result = $(this).attr("data-result");
		search_result = JSON.parse(search_result);
		console.log(search_result);
		search_result = prepare_search_result(search_result,{},0,0,[],[]);
		draw_chart(("search_result_chart_" + $(this).attr("id")),search_result);
	});
});


$(document).on('click','.entity',function(event){
	var entity = JSON.parse($(this).attr("data-entity"));
	var top_n_hit_ids = entity.top_n_hit_ids;
	var multiple = _.map(top_n_hit_ids,function(hit_id){

		return {id: hit_id, entity_id: entity.primary_entity_id}
	});

	console.log(multiple);
	// response is populated by js erb.
	$.ajax({
		  	url: "/results",
		  	type: "GET",
		  	dataType: "json",
		  	contentType: 'application/json',
		  	data:{"multiple" : JSON.stringify(multiple)}
	});
});


