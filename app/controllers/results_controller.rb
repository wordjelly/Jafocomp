class ResultsController < ApplicationController

	## overriden from application controller.
	def set_meta_information
	  	@title = DEFAULT_TITLE
	  	@meta_description = DEFAULT_META_DESCRIPTION
	  	@twitter_username = TWITTER_USERNAME
	    @social_title = @result["social_title"]
	    @social_description = @result["social_description"]
	    @social_url = @result["social_url"]
	    @social_image_url = @result["social_image_url"]
  	end

	
	def show
		@result = Result.es_find(params[:id],{entity_id: params[:entity_id]})
	end

	def permitted_params
		params.permit(:entity_id)
	end

end