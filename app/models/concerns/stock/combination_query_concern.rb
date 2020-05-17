module Concerns::Stock::CombinationQueryConcern
	
	extend ActiveSupport::Concern

	included do 

		def query(args={})

			## what is the primary and what is the impacted.
			## impacted is our stock

			## primary is the stock_id.
			## lets call it primary stock id instead.

			return if args.blank?
			return if ((args[:primary_stock_id].blank?) && (args[:indicator_id].blank?))
				
			query_string = ""

			unless args[:primary_stock_id].blank?

				puts "stock id is: #{args[:primary_stock_id]}"
				
				if primary_stock = Stock.find_or_initialize({:id => args[:primary_stock_id]})		

					puts "stock is:"
					puts primary_stock.to_s

					query_string += primary_stock.stock_name
				
				end 
			end

			unless args[:indicator_id].blank?
				if indicator = Indicator.find_or_initialize(:id => args[:indicator_id])
					query_string += indicator.stock_name
				end
			end

			from = args[:from] || 0

			q = Result.match_phrase_query_builder({
				:query => query_string,
				:direction => nil,
				:impacted_entity_id => nil,
				:from => from
			})

			puts q.to_s

			search_results = self.class.gateway.client.search body: q, index: "correlations", type: "result"

			## find the combination
			## if the from is different
			## then we have to 
			s = combination_from_hits({
				primary_stock: primary_stock,
				impacted_stock: self,
				search_results: search_results
			})

			## now from this combination set the shit, on self.

				

		end

	end

end