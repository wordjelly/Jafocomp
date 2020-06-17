module Concerns::Stock::ExchangeConcern

	extend ActiveSupport::Concern

	included do 

	end


	def entities(args={})

		query = {
			size: 100,
			query: {
				bool: {
					must: [
						{
							term: {
								stock_is_exchange: Concerns::Stock::EntityConcern::NO
							}
						},
						{
							term: {
								stock_exchange: self.stock_exchange
							}
						}
					]
				}
			}
		}

		#puts JSON.pretty_generate(query)

		search_request = Stock.search(query)

		search_request.response.hits.hits.map {|hit|
			s = Stock.new(hit["_source"])
			s.id = hit["_id"]
			s
		}	

	end

end