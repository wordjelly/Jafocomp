class ResultsController < ApplicationController

	## overriden from application controller.
	def set_meta_information
		# cannot be enforced.
	  	@title = DEFAULT_TITLE
	  	@meta_description = DEFAULT_META_DESCRIPTION
  	end
	
	def show
		@result = Result.es_find(params[:id],{})
	end

	def permitted_params
		params.permit(:entity_id)
	end

end