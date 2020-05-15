module Concerns::Stock::CombinationQueryConcern
	
	extend ActiveSupport::Concern

	included do 

		def query(args={})

			return if args.blank?
			return if ((args[:stock_id].blank?) && (args[:indicator_id].blank?))
				
			query_string = ""

			unless args[:stock_id].blank?
				if stock = Stock.find_or_initialize({:id => args[:stock_id]})

					query_string += stock.stock_name
				
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

			## you take the results if there are any.
			## you add them as stock_top_results
			## and we use that .

		end

	end

end