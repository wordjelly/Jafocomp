class StocksController < ApplicationController


	before_action :find, :only => [:show,:update]

	## so lets see if this shit works or not.
	## so lets test if it shows the first stock.
	def show
		respond_to do |format|
			format.html do 
				render :show
			end
			format.json do 
				render :json => @stock.as_json
			end
		end
	end

	def index
		search_request = Stock.search({
			query: {
				term: {
					stock_result_type: Stock::SINGLE
				}
			}
		})
		@stocks = []
		search_request.response.hits.hits.each do |hit|
			s = Stock.new(hit["_source"])
			s.id = hit["_id"]
			@stocks << s
		end
	end

	def find
		@stock = Stock.find_or_initialize(permitted_params.fetch("stock",{}).merge(:id => params[:id]))
	end
	
	## will expect an id.
	def update
		@stock.save
	end

	def permitted_params
		puts "params are: #{params}"
		k = params.permit(Stock.permitted_params).to_h
		puts k.to_s
		k
	end

end