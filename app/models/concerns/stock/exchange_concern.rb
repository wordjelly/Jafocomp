module Concerns::Stock::ExchangeConcern

	extend ActiveSupport::Concern

	included do 


	end

	def entities(args={})
		search_request = Stock.search({
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
								stock_exchange_name: self.stock_name
							}
						}
					]
				}
			}
		})

		search_request.response.hits.hits.map {|hit|
			s = Stock.new(hit["_source"])
			s.id = hit["_id"]
			s
		}	

	end

end