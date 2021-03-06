module Concerns::Stock::CombinationQueryConcern
	
	extend ActiveSupport::Concern

	included do 

		QUERY_SIZE = 10

		def query(args={})

			puts "Args coming into query are :#{args}"
			## so we have something called directin.
			## should be permitted on stock.
			## sort out frontend issues till end june.
			## then 10 days of july for the rest of it
			## by 15th we are out with this.
			## but then doesnt work with single entity.
			return if args.blank?
			return if ((args[:primary_stock_id].blank?) && (args[:indicator_id].blank?) && args[:trend_direction].blank? && args[:from].blank?)
				
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

			
			## so we can just render it.
			## as is.
			## do a nested function score query.
			self.set_top_results({
				:query => query_string,
				:direction => args[:trend_direction],
				:impacted_entity_id => self.id.to_s,
				:from => self.from
			})


			## why am i not including that ?
			## if there is a direction.
			## then it should be stored on the entity for the view

			self.trend_direction = args[:trend_direction]
			unless primary_stock.blank?
				self.stock_primary = primary_stock.stock_name
				self.stock_primary_id = primary_stock.id.to_s
			end
			self.stock_impacted = self.stock_name	
			self.stock_impacted_id = self.id.to_s	
			
			if args[:indicator_id].blank? and args[:primary_stock_id].blank? and args[:trend_direction].blank?
				self.stock_result_type = Concerns::Stock::EntityConcern::SINGLE
			else	
				self.stock_result_type = Concerns::Stock::EntityConcern::COMBINATION
			end
			## so this is for combination.
			## set title and description.
			## why components are not working, and about the do_index titles and descriptions.
			## this should be triggered.
			set_page_title_and_description
		end

	end

end