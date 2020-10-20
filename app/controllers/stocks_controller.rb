class StocksController < ApplicationController

	include Concerns::EntityControllerConcern

	def ticks
		respond_to do |format|
			format.json do 
				render :json => {entities: Logs::Entity.ticks({:exchange_name => params[:exchange_name], :entity_unique_name => params[:entity_unique_name]}), status: 200}
			end
		end
	end

	## params must have
	## :datapoint_index => 
	## :entity_id => 
	def update_tick_verified
		puts "came to update tick verified."

		update_response = Elasticsearch::Persistence.client.update :index => "tradegenie_titan", :id => params[:entity_id], :type => "doc", :body => {
			data: {
				script: {
					lang: 'painless',
					params: {
						datapoint_index: params[:datapoint_index].to_i
					},
					source: '''
						ctx._source.es_linked_list[params.datapoint_index].data_point.price_change_verified = 1;
					'''
				}
			}
		}

		puts "update tick verified update_response"
		puts update_response.to_s

	end

	def download_history
		respond_to do |format|
			format.json do 
				render :json => {poller_sessions: Logs::Entity.download_history(:entity_unique_name => params[:entity_unique_name]), status: 200}
			end
		end
	end

	def errors
		respond_to do |format|
			format.json do 
				render :json => {errors: Logs::Entity.errors(:entity_unique_name => params[:entity_unique_name]), status: 200}
			end
		end
	end

	def poller_history
		respond_to do |format|
			format.json do 
				render :json => {poller_history: Logs::Entity.poller_history(:entity_unique_name => params[:entity_unique_name]), status: 200}
			end
		end
	end
	
end