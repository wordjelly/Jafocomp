$(document).on('click','.show_entity_logs',function(event){
	$("#logs").html("");
	$("#stock_log").html("");
	var template = _.template($('#stock_log_template').html());
	$("#stock_log").append(template({}));
	
	get_stock_errors($(this).attr("data-entity-unique-name"));
	get_stock_download_history($(this).attr("data-entity-unique-name"));
	get_stock_poller_history($(this).attr("data-entity-unique-name"));
	get_stock_ticks($(this).attr("data-entity-unique-name"));
});


var get_stock_errors = function(entity_unique_name){
	console.log("entity errors are:");
	$.get("/stock_errors.json",{entity_unique_name : entity_unique_name}).done(function(data){
		$("#stock_errors").html("");
		var template = _.template($('#stock_errors_template').html());
		$("#stock_errors").append(template({errors : data.errors}));
	});
}

var get_stock_download_history = function(entity_unique_name){
	$.get("/stock_download_history.json",{entity_unique_name : entity_unique_name}).done(function(data){
		console.log("the download history data is:");
		console.log(data);
		var poller_sessions = data.poller_sessions;
		$("#stock_download_history").html("");
		var template = _.template($('#stock_download_history_template').html());
		$("#stock_download_history").append(template({poller_sessions : poller_sessions}));
	});
}	

var get_stock_ticks = function(entity_unique_name){
	$.get("/stock_ticks.json",{entity_unique_name : entity_unique_name}).done(function(data){
		console.log("the stock ticks data is:");
		console.log(data);
		var entities = data.entities;
		$("#stock_ticks").html("");
		var template = _.template($('#stock_ticks_template').html());
		$("#stock_ticks").append(template({entities : entities}));
	});
}

var get_stock_poller_history = function(entity_unique_name){
	$.get("/stock_poller_history.json",{entity_unique_name : entity_unique_name}).done(function(data){
		console.log("the stock poller_history response:");
		console.log(data);
		$("#stock_poller_history").html("");
		var template = _.template($('#stock_poller_history_template').html());
		$("#stock_poller_history").append(template(data));
	});	
}


$(document).on('click','.update_tick_verified',function(event){
	var entity_id = $(this).attr("data-entity-id");
	var datapoint_index = $(this).attr("data-datapoint-index");
	$.post('/update_tick_verified.json',{entity_id : entity_id, datapoint_index : datapoint_index});
})