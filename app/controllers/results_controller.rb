class ResultsController < ApplicationController

	## overriden from application controller.
	def set_meta_information
	  	@title = DEFAULT_TITLE
	  	@meta_description = DEFAULT_META_DESCRIPTION
	  	@twitter_username = TWITTER_USERNAME
	    @social_title = @result["_source"]["social_title"]
	    @social_description = @result["_source"]["social_description"]
	    @social_url = @result["_source"]["social_url"]
	    @social_image_url = @result["_source"]["social_image_url"]
  		@facebook_image_url = @result["_source"]["facebook_image_url"]
  	end

	def show
		@result = Result.es_find(params[:id],{entity_id: params[:entity_id]})
		puts "result becomes:"
		puts JSON.pretty_generate(@result)
		set_meta_information
	end

	def permitted_params
		params.permit(:entity_id)
	end

end