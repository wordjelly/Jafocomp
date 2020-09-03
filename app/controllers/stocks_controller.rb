class StocksController < ApplicationController

	include Concerns::EntityControllerConcern
		
	def ticks
		respond_to do |format|
			format.json do 
				render :json => {entities: Logs::Entity.ticks(:exchange_name => params[:exchange_name]), status: 200}
			end
		end
	end

	def download_history
		respond_to do |format|
			format.json do 
				render :json => {poller_sessions: Logs::Entity.download_history(:entity_unique_name => params[:entity_unique_name]), status: 200}
			end
		end
	end
	
end