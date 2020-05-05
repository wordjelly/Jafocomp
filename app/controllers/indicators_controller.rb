class IndicatorsController < ApplicationController

	before_action :find, :only => [:show,:update]

	## so lets see if this shit works or not.
	## so lets test if it shows the first stock.
	def show
		respond_to do |format|
			format.html do 
				render :show
			end
		end
	end

	def index
		search_request = Indicator.search({
			query: {
				term: {
					stock_result_type: Indicator::SINGLE
				}
			}
		})
		@stocks = []
		search_request.response.hits.hits.each do |hit|
			s = Indicator.new(hit["_source"])
			s.id = hit["_id"]
			@stocks << s
		end
	end

	def find
		@stock = Indicator.find_or_initialize(permitted_params.fetch("stock",{}).merge(:id => params[:id]))
	end
	
	## will expect an id.
	def update
		@stock.save
	end

	def update_many
		Indicator.update_many
	end

	def permitted_params
		puts "params are: #{params}"
		k = params.permit(Indicator.permitted_params).to_h
		puts k.to_s
		k
	end

end