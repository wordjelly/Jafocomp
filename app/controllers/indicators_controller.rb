class IndicatorsController < ApplicationController

	include Concerns::EntityControllerConcern

=begin
	before_action :find, :only => [:show,:update]

	## its going to be the same thing,s
	## gotta knock if this instance variable.

	def show
		@stock = @indicator
		respond_to do |format|
			format.html do 
				render "/stocks/show.html.erb"
			end
		end
	end


	def index
		search_request = Stock.search({
			query: {
				bool: {
					must: [
						{
							term: {
								stock_result_type: Stock::SINGLE
							}
						},
						{
							term: {
								stock_is_exchange: Concerns::Stock::EntityConcern::NO
							}
						},
						{
							term: {
								stock_is_indicator: Concerns::Stock::EntityConcern::YES
							}
						}
					]
				}
			}
		})

		@stocks = []

		## so these are exchanges -> and can be easily rendered.

		search_request.response.hits.hits.each do |hit|
			s = Stock.new(hit["_source"])
			s.id = hit["_id"]
			@stocks << s
		end

		# now group the stocks.

		# should render stock sindex
		respond_to do |format|
			format.html do 
				render "/stocks/index.html.erb"
			end
		end


	end

	def find
		@indicator = Indicator.find_or_initialize(permitted_params.fetch("indicator",{}).merge(:id => params[:id]))
	end
	
	## will expect an id.
	def update
		@indicator.save
	end

	def permitted_params
		puts "params are: #{params}"
		k = params.permit(Indicator.permitted_params).to_h
		puts k.to_s
		k
	end

=end

end