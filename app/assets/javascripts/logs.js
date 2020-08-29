$(document).on('click','#show_logs',function(event){
	console.log("clicked logs");
	$.get('/download_sessions.json').done(function(data) {
		var download_sessions = data["download_sessions"];
		// make the template and render.
		if(_.isUndefined(template)){
			var template = _.template($('#download_session_template').html());
		}
		$("#logs").html("");
		_.each(download_sessions,function(download_session){
			$('#logs').append(template(download_session));
		});
	});	
});

$(document).on('click','.exchange',function(event){
	$(this).next().slideToggle();
})

$(document).on('click','.filter_exchange',function(event){
	var exchange_name = $(this).attr("data-exchange-name");
	$.get('/download_sessions.json',{exchanges : [exchange_name]}).done(function(data) {
		var download_sessions = data["download_sessions"];
		// make the template and render.
		if(_.isUndefined(template)){
			var template = _.template($('#download_session_template').html());
		}
		$("#logs").html("");
		_.each(download_sessions,function(download_session){
			$('#logs').append(template(download_session));
		});
	});	
})

$(document).on('click','.filter_entity',function(event){
	var entity_name = $(this).attr("data-entity-name");
	$.get('/download_sessions.json',{entities: [entity_name]}).done(function(data) {
		var download_sessions = data["download_sessions"];
		// make the template and render.
		if(_.isUndefined(template)){
			var template = _.template($('#download_session_template').html());
		}
		$("#logs").html("");
		_.each(download_sessions,function(download_session){
			$('#logs').append(template(download_session));
		});
	});	
})

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

$(document).on('click','.show_session_logs',function(event){
	$.get('/poller_sessions.json').done(function(data) {
		console.log(data);
		var poller_session_rows = data["poller_session_rows"];
		console.log("these are the poller session rows");
		console.log(poller_session_rows);
		add_poller_session_template();
		console.log("added poller session template");
		$("#poller_session_table_body").html("");
		var template = _.template($('#poller_sessions_table_row_template').html());
		_.each(poller_session_rows,function(row){
			$("#poller_session_table_body").append(template(row));
		});	
	});
});

$(document).on('click','.poller_session_table_row',function(event){
	var poller_session_id = $(this).attr("data-poller-session-id");
	$.get('/poller_session.json',{poller_session_id : poller_session_id}).done(function(data){
		var poller_session_rows = data.poller_session_rows;
		console.log("got response of individual log event");
		console.log(poller_session_rows);
		$("#poller_session").html("");
		var template = _.template($('#poller_sessions_id_template').html());
		$("#poller_session").append(template({poller_session_rows :poller_session_rows}));
	});	
})

$(document).on('click','.stock_ticks',function(event){
	var exchange_name = $(this).attr("data-exchange-name");
	$.get('/stock_ticks.json',{exchange_name : exchange_name}).done(function(data) {
		console.log("response data is:");
		console.log(data);
	});
});