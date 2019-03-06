class WelcomeController < ApplicationController

	def index

	end	

	## so we have a tooltip request.
	## for things that are to be shown as the information.
	## we send the match_query and show the first hit, as the result.


	def search

		context = permitted_params[:context]
		query = permitted_params[:query]
		information = permitted_params[:information]
		suggest_query = permitted_params[:suggest_query]
		last_successfull_query = permitted_params[:last_successfull_query]
		results = nil

		if query
			results = Result.suggest_r({:prefix => query, :context => context, :last_successfull_query => last_successfull_query})
		end

		if information 
			results = Result.information({:information => information})
		end

		respond_to do |format|
			format.json do 
				render :json => {results: results, status: 200}
			end
		end	
	end


	def permitted_params
		## context will be a single string.
		params.permit(:query,{:context => []},:suggest_query,:information)
	end

end
