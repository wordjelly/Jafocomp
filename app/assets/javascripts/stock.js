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

		var exchange_name = $(this).attr("id");
		// response is populated by js erb.
		$.ajax({
			  	url: "/results/multiple_results",
			  	type: "POST",
			  	beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
			  	dataType: "json",
			  	contentType: 'application/json',
			  	data: JSON.stringify({"multiple" : multiple, "exchange_name" : exchange_name }),
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


var hide_exchange_entity_combinations = function(exchange_name){
	$(exchange_name + "_entity_combinations").find(".entity_combinations").each(function(index){
		$(this).hide();
	});		
}

/******
FOR SHOWING THE COMBINATIONS
******/

var load_entity_combinations = function(_this,entity_id){

	var entity = get_entity_data(entity_id);

	var top_n_hit_ids = entity.top_n_hit_ids;
	
	var multiple = _.map(top_n_hit_ids,function(hit_id){
		return {id: hit_id, entity_id: entity.primary_entity_id}
	});

	console.log(multiple);

	$.ajax({
		  	url: "/results/multiple_results",
		  	type: "POST",
		  	beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
		  	dataType: "script",
		  	contentType: 'application/json',
		  	data: JSON.stringify({"multiple" : multiple}),
		  	success: function(response,status,jqxhr){
		  		/***
		  		_.each(_.chunk(response.results,2),function(pair,index,list){
		  			var template = _.template($('#result_card_template').html());
		  			var row_id = entity.primary_entity_id + "-row-" + String(index) ;
		  			$("#" + entity.primary_entity_id).find(".entity_combinations").append('<div class="row combination_row" id="' + row_id + '"></div>')
		  			_.each(pair,function(result){

		  				$("#" + row_id).append(template(result));
		  			});
		  		});
		  		update_charts();
		  		***/
		  	}
	});
}

var entity_loaded = function(entity_id){

}


var show_entity_combinations = function(_this,entity_id){
	if(entity_loaded(entity_id) != true){
		load_entity_combinations(event,entity_id);
	}

}

var show_exchange_entities = function(_this){
	$("#" + _this.attr("id") + "_entities").slideToggle();
}

/***
@return[Array] of entity ids
***/
var get_exchange_entities = function(_this){
	var entity_ids = [];
	$.each($("#" + _this.attr("id") + "_entities").find(".entity"),function(index){
		entity_ids.push($(this).attr("id"));
	});
	return entity_ids;
}

// target today -> combination page, and its pagination.
// 
var get_entity_data = function(entity_id){
	//$("#" + entity_id)
	var entity_div = $("#" + entity_id)

	var entity = JSON.parse(entity_div.attr("data-entity"));
	
	return entity;
}

var toggle_exchange = function(_this){
	show_exchange_entities(_this);
	show_entity_combinations(_this,get_exchange_entities(_this)[0]);
}

$(document).on('click','.exchange',function(event){

	toggle_exchange($(this));

});