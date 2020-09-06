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
