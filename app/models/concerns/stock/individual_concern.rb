module Concerns::Stock::IndividualConcern
	
	extend ActiveSupport::Concern

	included do 

		def set_top_results(args={})
				
			
			self.stock_top_results = Result.nested_function_score_query(args)[0..4].map{|c| Result.build_setup(c) }
			
			Rails.logger.debug("setting top results of entity #{self.stock_name}, with args #{args}, total results :#{self.stock_top_results.size}")

		end


	end

end