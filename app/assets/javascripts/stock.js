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


////hide_exchange_entity_combinations("<%= @exchange_name %>");

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


/**
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
		console.log("Exchange name:" + exchange_name);
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
**/

/***
var hide_exchange_entity_combinations = function(exchange_name){
	console.log("came to hide enitty enxchange combinations");

	$(exchange_name + "_entity_combinations").find(".entity_combinations").each(function(index){
		$(this).hide();
	});		
}
***/

/******
FOR SHOWING THE COMBINATIONS
******/

var load_entity_combinations = function(_this,entity_id){

	var entity = get_entity_data(entity_id);

	var top_n_hit_ids = entity.top_n_hit_ids;
	
	var multiple = _.map(top_n_hit_ids,function(hit_id){
		return {id: hit_id, entity_id: entity.impacted_entity_id}
	});

	var exchange_name = _this.attr("id");

	var primary_entity_id = entity_id;
	
	$.ajax({
		  	url: "/results/multiple_results",
		  	type: "POST",
		  	beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
		  	dataType: "script",
		  	contentType: 'application/json',
		  	data: JSON.stringify({"multiple" : multiple, "exchange_name" : exchange_name, "entity_id" : primary_entity_id}),
		  	success: function(response,status,jqxhr){
		  	}
	});
}

var entity_loaded = function(entity_id){
	var entity_combination_holder = $("#entity_combination_" + entity_id);
	console.log("existing combiations length is:");
	console.log(entity_combination_holder.find(".summary_card").length);
	return entity_combination_holder.find(".summary_card").length > 0;
}


/***
@param[JqueryNode] _this : 
@param[String] entity_id : 
@param[Boolean] show :
@return[nil]
***/
var toggle_entity_combinations = function(_this,entity_id){
	$("#entity_combination_" + entity_id).toggle();
	if($("#entity_combination_" + entity_id).is(':visible')){
		if(entity_loaded(entity_id) != true){
			load_entity_combinations(_this,entity_id);
		}
	}
	else{
		console.log("its not visible");
	}
}

var toggle_entity_combinations_except = function(_this,entity_id){
	console.log("came to toggle entity combinations except");
	$("#" + _this.attr("id") + "_entity_combinations").find(".entity_combination").each(function(index){
		console.log("foudn entity combination");
		console.log($(this));
		console.log("this id is:" + $(this).attr("id"));
		console.log("entity id is:" + entity_id);
		if($(this).attr("id").indexOf(entity_id) !== -1){
			console.log("came to toggle entity combinations");
			toggle_entity_combinations(_this,entity_id);
		}
		else{
			$(this).hide();
		}
	});
}

// so this should 
var toggle_exchange_entities = function(_this){
	$("#" + _this.attr("id") + "_entities").toggle();
}

var toggle_exchange_combinations = function(_this){
	$("#" + _this.attr("id") + "_entity_combinations").toggle();
}

/***
@return[Array] of entity ids
***/
var get_exchange_entities = function(_this){
	//console.log("came to get exchange entities");
	var entity_ids = [];
	$.each($("#" + _this.attr("id") + "_entities").find(".entity"),function(index){
		entity_ids.push($(this).attr("id"));
	});
	//console.log("entity ids are:");
	//console.log(entity_ids);
	//console.log("---------------");
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

/***

***/


// so you want to see the combinations.
$(document).on('click','.stock_exchange',function(event){
	toggle_exchange_entities($(this));
	toggle_exchange_combinations($(this));
	toggle_entity_combinations_except($(this),get_exchange_entities($(this))[0]);
	// select first entity.

});


$(document).on('click','.entity',function(event){
	var exchange_div = $(this).attr("data-exchange-div-id");
	toggle_entity_combinations_except(exchange_div,$(this).attr("id"));
});