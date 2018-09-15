class WelcomeController < ApplicationController

	def index

	end	

	def search
		results = Auth::Search::Main.search({:query_string => params[:query]})
		respond_to do |format|
			format.json do 
				render :json => {results: results, status: 200}
			end
		end	
	end

end
