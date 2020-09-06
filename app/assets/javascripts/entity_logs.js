$(document).on('click','.download_history',function(event){
	console.log("clicked on download history");
	var entity_unique_name = $(this).attr("data-entity-unique-name");
	$.get("/download_history.json",{entity_unique_name : entity_unique_name}).done(function(data){
		console.log("the download history data is:");
		console.log(data);
		var poller_sessions = data.poller_sessions;
		$("#logs").html("");
		var template = _.template($('#download_history_template').html());
		$("#logs").append(template({poller_sessions : poller_sessions}));
	});
});	