class IndicatorsController < ApplicationController

	before_action :find, :only => [:show,:update]

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
				bool: {
					must: [
						{
							term: {
								stock_result_type: Indicator::SINGLE
							}
						},
						{
							term: {
								stock_information_type: "indicator"
							}
						}
					]
				}
			}
		})
		@indicators = []
		search_request.response.hits.hits.each do |hit|
			s = Indicator.new(hit["_source"])
			s.id = hit["_id"]
			@indicators << s
		end
	end

	def find
		@indicator = Indicator.find_or_initialize(permitted_params.fetch("indicator",{}).merge(:id => params[:id]))
	end
	
	## will expect an id.
	def update
		@indicator.save
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