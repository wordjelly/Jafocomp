class WelcomeController < ApplicationController

	def index

	end	

	def search

		#results = Auth::Search::Main.completion_suggester_search({:prefix => params[:query], :context => params[:context]})
		puts "these are the context sent into the params --------------------------------------"
		puts params[:context]

		results = Result.suggest_r({:prefix => params[:query], :context => params[:context]})

		respond_to do |format|
			format.json do 
				render :json => {results: results, status: 200}
			end
		end	
	end

end
