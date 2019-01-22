class WelcomeController < ApplicationController

	def index

	end	

	## so we have a tooltip request.
	## for things that are to be shown as the information.
	## we send the match_query and show the first hit, as the result.


	def search

		#results = Auth::Search::Main.completion_suggester_search({:prefix => params[:query], :context => params[:context]})
		puts "these are the context sent into the params --------------------------------------"
		puts params[:context]

		context = permitted_params[:context]
		query = permitted_params[:query]
		information = permitted_params[:information]

		results = nil

		if query
			puts "query is: #{query}"
			puts "context is: #{context.to_s}"
			results = Result.suggest_r({:prefix => query, :context => context})
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
		params.permit(:query,{:context => []},:information)
	end

end
