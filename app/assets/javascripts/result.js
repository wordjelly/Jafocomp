$(document).ready(function(){
	console.log("Ready");
	console.log($("#_result"));
	var result = $("#_result");
	console.log(result);
	if(!_.isEmpty(result)){
		var search_result = $("#_result").attr("data-result");
		search_result = JSON.parse(search_result);
		console.log(search_result);
		display_search_results([search_result],"");
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

};
