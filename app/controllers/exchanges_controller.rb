class ExchangesController < ApplicationController

	include Concerns::EntityControllerConcern
	
	def index

		puts "came to index action in exchanges controller----------"

		@entity = get_resource_class.new(permitted_params.fetch("entity",{}))

		@entity.stock_is_exchange = Concerns::Stock::EntityConcern::YES
			
		@entities_by_exchange = @entity.do_index

		@exchanges = @entities_by_exchange.values.map{|c| c[:stocks]}.flatten

		puts "exchanges are:"
		puts @exchanges.map{|c| c.stock_name}

		set_individual_action_meta_information({
			:title => @exchanges.first.page_title,
			:description =>@exchanges.first.page_description
		})

		
		respond_to do |format|
			format.html do 
				render "/exchanges/index.html.erb"
			end

			format.js do 
				render "/exchanges/index.js.erb"
			end
		end

	end	

	## so we go with show, and fire a get_components accessor on it.

	def all
		respond_to do |format|
			format.json do 
				render :json => {exchanges: Logs::Exchange.all(:exchange_name => params[:exchange_name]), status: 200}
			end
		end
	end

	def summary
		respond_to do |format|
			format.json do 
				render :json => {datapoints: Logs::Exchange.summary(:exchange_name => params[:exchange_name], :entity_unique_names => params[:entity_unique_names]), status: 200}
			end
		end
	end
	

end