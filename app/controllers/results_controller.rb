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

	def index
		k = permitted_params
		puts k.to_s
		puts k.fetch(:multiple)
		@results = Result.es_find_multi(k.fetch(:multiple,[]))
	end

	def multiple_results
		k = permitted_params
		puts k.to_s
		puts k.fetch(:multiple).to_s
		@results = Result.es_find_multi(k.fetch(:multiple,[]))
		respond_to do |format|
			format.json do 
				#puts "came to render json"
				render :json => {results: @results, status: 200}
			end
		end
	end

	def permitted_params
		puts params.to_s
		params.permit(:entity_id, :multiple => [:id, :entity_id]).to_h
	end

end