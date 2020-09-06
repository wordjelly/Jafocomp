var add_poller_session_template = function(){
	
	if($("#poller_sessions_table").length > 0){

	}
	else{
		var template = _.template($('#poller_sessions_table_template').html());
		console.log("made template");
		$("#logs").html("");
		$("#logs").append(template({}));
	}
}

// filter for a particular entity
// i want to get a list of the entities for every exchange
// or at least have them on autocomplete ?
// to get the unique names.
// now prettify the logs
// then we come to thsi.

var get_poller_sessions = function(args){
	$.get('/poller_sessions.json',args).done(function(data) {
		console.log(data);
		
		var poller_session_rows = data["poller_session_rows"];
		
		

		//console.log("these are the poller session rows");
		//console.log(poller_session_rows);
		add_poller_session_template();
		//console.log("added poller session template");
		$("#poller_session_table_body").html("");
		var template = _.template($('#poller_sessions_table_row_template').html());

		_.each(poller_session_rows,function(row){
			$("#poller_session_table_body").append(template(row));
		});	

		if(!_.isEmpty(poller_session_rows)){
		
			var newest_poller_session_date = _.first(poller_session_rows).start_time;
			
			var oldest_poller_session_date = _.last(poller_session_rows).start_time;

			$("#newer_poller_sessions").attr("data-time",newest_poller_session_date);
		
			$("#older_poller_sessions").attr("data-time",oldest_poller_session_date);
			
		}

	});
}

var get_poller_session = function(args){
	$.get('/poller_session.json',args).done(function(data){
		var poller_session_rows = data.poller_session_rows;
		//console.log("got response of individual log event");
		//console.log(poller_session_rows);
		$("#logs").html("");
		var template = _.template($('#poller_sessions_id_template').html());
		$("#logs").append(template({poller_session_rows :poller_session_rows}));
	});	
}

$(document).on('click','.show_session_logs',function(event){
	get_poller_sessions({});
});

$(document).on('click','#newer_poller_sessions',function(event){
	get_poller_sessions({poller_sessions_from : $(this).attr("data-time")});
});

$(document).on('click','#older_poller_sessions',function(event){
	get_poller_sessions({poller_sessions_upto : $(this).attr("data-time")});
});

$(document).on('click','.poller_session_table_row',function(event){
	var poller_session_id = $(this).attr("data-poller-session-id");
	var query_params = JSON.parse($(this).attr("data-query-params"));
	get_poller_session($.extend({poller_session_id : poller_session_id},query_params));
});

$(document).on('click','.search_poller_sessions',function(event){
	
	var poller_sessions_from = $("#poller_sessions_from_search").val();
	
	var poller_sessions_upto = $("#poller_sessions_upto_search").val();
	
	var poller_session_id = $("#poller_session_id_search").val();

	var entity_unique_name = $("#poller_sessions_entity_unique_name").val();

	var indice = $("#poller_sessions_indice").val();
	
	get_poller_sessions({
		poller_sessions_upto : poller_sessions_upto,
		poller_sessions_from : poller_sessions_from,
		poller_session_id : poller_session_id,
		entity_unique_name: entity_unique_name,
		indice: indice
	});
});

$(document).on('click','.filter_by_entity',function(event){
	var entity_unique_name = $(this).attr("data-name");
	get_poller_sessions({
		entity_unique_name : entity_unique_name
	});
});

// so this shit works now.
// now what
// what about the entity history view ?
// so can we search by the entity name ?

$(document).on('click','.filter_by_exchange',function(event){
	var indice = $(this).attr("data-name");
	get_poller_sessions({
		indice : indice
	});
});