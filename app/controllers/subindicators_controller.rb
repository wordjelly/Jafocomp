class SubindicatorsController < ApplicationController

	def show
		@result = Result.es_find(params[:id],entity_id)
	end

	def permitted_params
		params.permit(:entity_id)
	end

end