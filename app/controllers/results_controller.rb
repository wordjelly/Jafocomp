class ResultsController < ApplicationController

	## do we go with cloudinary and twitter first ?
	## and then google.
	## so first make this
	## basically the thing is SEO right now.
	## get it working with google visualizer.
	## related queries
	## and other links.
	def show
		@result = Result.es_find(params[:id],entity_id)
	end

	def permitted_params
		params.permit(:entity_id)
	end

end