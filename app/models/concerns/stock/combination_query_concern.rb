module Concerns::Stock::CombinationQueryConcern
	
	extend ActiveSupport::Concern

	included do 

		def query(args={})

			## so we have something called directin.
			## should be permitted on stock.

			return if args.blank?
			return if ((args[:primary_stock_id].blank?) && (args[:indicator_id].blank?))
				
			query_string = ""

			unless args[:primary_stock_id].blank?

				#puts "stock id is: #{args[:primary_stock_id]}"
				
				if primary_stock = Stock.find_or_initialize({:id => args[:primary_stock_id]})		

					#puts "stock is:"
					#puts primary_stock.to_s

					query_string += primary_stock.stock_name
				
				end 
			end

			unless args[:indicator_id].blank?
				if indicator = Indicator.find_or_initialize(:id => args[:indicator_id])
					query_string += indicator.stock_name
				end
			end

			self.from = args[:from] || 0

			## do a nested function score query.
			self.set_top_results({
				:query => query_string,
				:direction => args[:direction],
				:impacted_entity_id => self.id.to_s,
				:from => self.from
			})


			## why am i not including that ?


			self.stock_primary = primary_stock.stock_name
			self.stock_primary_id = primary_stock.id.to_s
			self.stock_impacted = self.stock_name	
			self.stock_impacted_id = self.id.to_s		
			self.stock_result_type = Concerns::Stock::EntityConcern::COMBINATION


		end

	end

end