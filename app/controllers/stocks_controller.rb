class StocksController < ApplicationController

	before_action :find, :only => [:show,:update]

	## will expect a name or an id.
	def show
		results = @stock.get_results
	end

	def find
		stock_params = permitted_params.fetch("stock",{}).merge(:id => params[:id])
		@stock = Stock.find_or_initialize(stock_params)
	end
	
	## will expect an id.
	def update
		@stock.save
	end

	def permitted_params
		puts "params are: #{params}"
		params.permit(Stock.permitted_params)
	end

end