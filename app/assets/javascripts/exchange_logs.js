$(document).on('click','.exchange_summary',function(event){
	var exchange_name = $(this).attr("data-exchange-name");
	get_entity_unique_names({exchange_name : exchange_name}).then(function(data){
		var entity_unique_names = _.first(data.exchanges).entity_names;;
		$.post('/exchange_summary.json',{entity_unique_names : entity_unique_names, exchange_name : exchange_name }).done(function(data) {
			console.log("response data is:");
			console.log(data);
			$("#exchange_summary").html("");
			var template = _.template($('#exchange_summary_template').html());
			$("#exchange_summary").append(template(data));
		});
		download_history({exchange_name : exchange_name});
	})
});

var get_entity_unique_names = function(args){
	return $.get("/all_exchanges",{exchange_name : args["exchange_name"]});
}

var download_history = function(args){
	$.post("/exchange_download_history",{exchange_name : args["exchange_name"]}).then(function(data){
		console.log("exchange download history data is:");
		console.log(data);
		$("#exchange_download_history").html("");
		var template = _.template($('#exchange_download_history_template').html());
		$("#exchange_download_history_template").append(template(data));
	});
}