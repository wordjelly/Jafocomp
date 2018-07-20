class WelcomeController < ApplicationController

	def index

	end	

	def search
		results = Result.all.to_a
		respond_to do |format|
			format.json do 
				render :json => {results: results.to_json, status: 200}
			end
		end	
	end

end
