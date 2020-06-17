require 'elasticsearch/persistence/model'

class Exchange

	## we include them as concerns.
	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern
	include Concerns::Stock::IndividualConcern
	include Concerns::Stock::CombinationConcern
	include Concerns::BackgroundJobConcern
	include Concerns::Stock::EntityConcern

=begin
	attr_accessor :show_components
	attr_accessor :combine_with
	
	attr_accessor :components

	

	MAX_STOCKS_IN_EXCHANGE = 100

	after_find do |document|
		unless document.show_components.blank?
			document.load_components
		end
	end

	def load_components
		query = {
			bool: {
				must: [
					{
						term: {
							stock_result_type: SINGLE
						}
					},
					{
						term: {
							stock_is_indicator: NO
						}
					},
					{
						term: {
							stock_is_exchange: NO
						}
					},
					{
						term: {
							stock_exchange: self.stock_name
						}
					}
				]
			}	
		}

		search_request = Stock.search({
			size: MAX_STOCKS_IN_EXCHANGE,
			query: query
		})

		self.components = search_request.response.hits.hits.map{|hit|
			stock = Stock.new(hit["_source"])
			stock.id = hit["_id"]
			stock	
		}

	end
=end
end