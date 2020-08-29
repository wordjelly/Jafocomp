class StocksController < ApplicationController

	include Concerns::EntityControllerConcern
		
	def ticks
		respond_to do |format|
			format.json do 
				render :json => {entities: Logs::Entity.ticks(:exchange_name => params[:exchange_name]), status: 200}
			end
		end
	end



end