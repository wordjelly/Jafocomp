class ExchangesController < ApplicationController

	include Concerns::EntityControllerConcern
	
	## override the index action.
	## i think use it for a bit, and try to do the tests simultaneously
	## but that's not possible.
	## i want billing statement, working for outsourcing, and prepaid option.
	## and it should work with the lis.
	## that much i can do without too much trouble.
	## we can use default timings ?
	## at bare minimum.

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

end