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


var update_charts = function(){
	$(".result").each(function(index){
		console.log("iterating result");
		console.log("iterating");
		var search_result = $(this).attr("data-result");
		search_result = JSON.parse(search_result);
		console.log(search_result);
		search_result = prepare_search_result(search_result,{},0,0,[],[]);
		draw_chart(("search_result_chart_" + $(this).attr("id")),search_result);
	});
}

$(document).on('click','.entity',function(event){
	$(this).find(".entity_combinations").slideToggle();
	if($(this).find(".combination_row").length > 0){
		//$(this).find(".entity_combinations").hide();
	}
	else
	{
		//$(this).find(".entity_combinations").show();
		var entity = JSON.parse($(this).attr("data-entity"));
		var top_n_hit_ids = entity.top_n_hit_ids;
		var multiple = _.map(top_n_hit_ids,function(hit_id){

			return {id: hit_id, entity_id: entity.primary_entity_id}
		});

		console.log(multiple);
		// response is populated by js erb.
		$.ajax({
			  	url: "/results/multiple_results",
			  	type: "POST",
			  	beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
			  	dataType: "json",
			  	contentType: 'application/json',
			  	data: JSON.stringify({"multiple" : multiple}),
			  	success: function(response,status,jqxhr){
			  		_.each(_.chunk(response.results,2),function(pair,index,list){
			  			var template = _.template($('#result_card_template').html());
			  			var row_id = entity.primary_entity_id + "-row-" + String(index) ;
			  			$("#" + entity.primary_entity_id).find(".entity_combinations").append('<div class="row combination_row" id="' + row_id + '"></div>')
			  			_.each(pair,function(result){

			  				$("#" + row_id).append(template(result));
			  			});
			  		});
			  		update_charts();
			  	}
		});
	}
});


