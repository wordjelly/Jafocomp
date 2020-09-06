$(document).on('click','.stock_ticks',function(event){
	var exchange_name = $(this).attr("data-exchange-name");
	$.get('/stock_ticks.json',{exchange_name : exchange_name}).done(function(data) {
		console.log("response data is:");
		console.log(data);
		var entities = data.entities;
		console.log("individual entities");
		console.log(entities);
		$("#logs").html("");
		var template = _.template($('#stock_ticks_template').html());
		$("#logs").append(template({entities : entities}));
	});
});