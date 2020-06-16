module Concerns::Stock::IndividualConcern
	
	extend ActiveSupport::Concern

	included do 

		def set_top_results(args={})
			
			## pass self into the arguments, so that attribute like total_results can be set on it.
			## to allow for stat pagination on loading the exchange.
			self.stock_top_results = Result.nested_function_score_query(args.merge(:object => self))[0..4].map{|c| Result.build_setup(c) }
			
			Rails.logger.debug("setting top results of entity #{self.stock_name}, with args #{args}, total results :#{self.stock_top_results.size}")

		end

		def set_positive_results(args={})
			
			self.positive_results = Result.nested_function_score_query(args)[0..4].map{|c| Result.build_setup(c) }
			
			Rails.logger.debug("setting positive results of entity #{self.stock_name}, with args #{args}, total results :#{self.stock_top_results.size}")			

		end


		def set_negative_results(args={})

			self.negative_results = Result.nested_function_score_query(args)[0..4].map{|c| Result.build_setup(c) }
			
			Rails.logger.debug("setting negative results of entity #{self.stock_name}, with args #{args}, total results :#{self.stock_top_results.size}")

		end


	end

end