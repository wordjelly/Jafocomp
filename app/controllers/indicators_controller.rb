class IndicatorssController < ApplicationController

	def show

	end

	def index
		## we make an information query with type.
		## and then make ajax queries with the top five for that ?
		## can we do that ?
		## will we get a good enough permutation.
		## keep it simple.
		## just fire queries
		## for any where it already has
		## don't.
		## and maybe a word cloud ?
	end

	def permitted_params
		params.permit(:entity_id)
	end

end