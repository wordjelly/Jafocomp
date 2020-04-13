$(document).ready(function(){
	console.log("Ready");
	console.log($("#_result"));
	var result = $("#_result");
	console.log(result);
	if(!_.isEmpty(result)){
		var search_result = $("#_result").attr("data-result");
		search_result = JSON.parse(search_result);
		display_search_results([search_result],"");
		update_twitter_cards_data(search_result);
		$(".search_result_card").first().show();
	}
	else{
		console.log("no result");
	}
	// probably won't be needed later on.
	// we use a recaptcha
	// and a signed upload
	// with signed_upload we control -> the rate of upload
	// 
	//load_cloudinary_button();
	//if($.fn.cloudinary_fileupload !== undefined) {
    //	$("input.cloudinary-fileupload[type=file]").cloudinary_fileupload();
  	//}
});


var load_cloudinary_button = function(){
	$('#upload_widget_opener').cloudinary_upload_widget(
	  get_widget_options(),
	  function(error, result) { 
	     var results_array = result[0];
	     var secure_url = results_array["secure_url"];
	     loadImage(secure_url,90,60,"#uploaded_image");
	});
}

var update_title_and_description = function(search_result){
	$("#title").val(search_result.setup);
	$("#meta_description").val(search_result.description);
};

var update_twitter_cards_data = function(search_result){
	/****
	image 
	****/
	// test this and see if it works.
	// add the share this button to the individual cards.
	var ratios = [0,20,35,50,65,80,95];
	var min_diff = null;
	var min_diff_ratio = null;
	if(search_result.rises_or_falls == "falls"){
		ratios = _.map(ratios,function(el){100 - el});
	}
	_.each(ratios,function(el){
		var diff = Math.abs(el - search_result.percentage);
		if(_.isNull(min_diff)){
			min_diff = diff;
			min_diff_ratio = el;
		}
		else{
			if(diff < min_diff){
				min_diff = diff;
				min_diff_ratio = el;
			}
		}
	});
	var image_url = "up_" + String(min_diff_ratio) + ".png";

	// same for facebook and twitter here.
	// but for facebook we need the social url also, 
	// that comes from the search result.
	$(".social_image").each(function(el){
		el.attr("content",image_url);
	});
	// he's gonna tweet ?
	$(".social_title").each(function(el){
		el.attr("content",search_result.setup);
	});

	$(".social_description").each(function(el){
		el.attr("content",search_result.description);
	});

	$(".social_url").each(function(el){
		el.attr("content",search_result.url);
	});
};
