module Concerns::Stock::CombinationConcern
	
	extend ActiveSupport::Concern

	included do 

		def update_combinations
			names_by_index = get_all_other_stock_names
			# now a bulk search query ?
			names_by_index.keys.each do |index|
				names = names_by_index[index]
				names.each_slice(10) do |slice|
					## each search_request should have an index and a body.
					search_requests = slice.map{|c|
						{
							index: "correlations",
							body: {
								query: Result.match_phrase_query_builder(c,nil,self.id.to_s)
							}
						}
					}
					multi_response = Stock.gateway.client.msearch body: search_requests

					multi_response["responses"].each do |response|
						
					end
				end 
			end
		end
		
		def get_all_other_stock_names
			
			other_stock_names_by_index = {}

			query = {
				bool: {
					must: [
						{
							term: {
								information_type: "entity"
							}
						}
					]
				}
			}

			response = Hashie::Mash.new Stock.gateway.client.search :body => {:size => 200, :query => query}, :index => "correlations", :type => "result"
			

			response.hits.hits.each do |hit|
				index_name = hit._source.information_exchange_name
				other_stock_names_by_index[index_name] ||= []
				other_stock_names_by_index[index_name] << hit._source.information_name
			end

			other_stock_names_by_index

		end

	end
end